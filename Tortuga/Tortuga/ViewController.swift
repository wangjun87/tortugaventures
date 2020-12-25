//
//  ViewController.swift
//  Tortuga
//
//  Created by admin on 2020/12/25.
//

import UIKit
import CoreData


class ViewController: UIViewController {
    
    @IBOutlet weak var tv: UITextView!
    
    var defaultSession: URLSession = URLSession(configuration: URLSessionConfiguration.default)

    var dataTask: URLSessionDataTask?
    
    var timer:Timer?
    
    var controller:HistoryViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        let delayInSeconds = 5.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) { [weak self] in
            self!.timer = Timer.scheduledTimer(timeInterval: 5, target: self!, selector: #selector(self!.requestGithub), userInfo: nil, repeats: true)
        }
        requestGithub()
    }
    
    // MARK: - request API
    @objc func requestGithub() {
        let urlStr = "https://api.github.com/"
        let url = URL(string: urlStr)
        dataTask = defaultSession.dataTask(with: url!) {
          data, response, error in
          if let error = error {
            self.saveCallHistory(data, url: urlStr, error: error.localizedDescription)
            print(error.localizedDescription)
          } else if let httpResponse = response as? HTTPURLResponse {
            self.saveCallHistory(data, url: urlStr, error: nil)
            if httpResponse.statusCode == 200 {
                self.showData(data)
            }else{
                print("something error")
            }
          }
        }
        dataTask?.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        controller = segue.destination as? HistoryViewController
    }
    
    // MARK: - save data to coredata
    func saveCallHistory(_ data:Data?,url:String,error:String?) {

        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
              return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "GithubCall", in: managedContext)!
            let githubCall = NSManagedObject(entity: entity, insertInto: managedContext)
            githubCall.setValue(data, forKeyPath: "response")
            githubCall.setValue(url, forKeyPath: "url")
            githubCall.setValue(Date(), forKeyPath: "ctime")
            githubCall.setValue(error, forKeyPath: "error")

            do {
              try managedContext.save()
            } catch let error as NSError {
              print("Could not save. \(error), \(error.userInfo)")
            }
            
            self.controller?.updateAction!()

        }
    }
    
    // MARK: - show data on the screen
    func showData(_ data: Data?) {
      do {
        if
          let data = data,
          let response = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions(rawValue:0)) as? [String: String] {
            let responseStr = String(decoding: data, as: UTF8.self)
            DispatchQueue.main.async {
                [weak self] in
                self!.tv.text = responseStr
            }
        } else {
          print("JSON Error")
        }
      } catch let error as NSError {
        print("Error parsing results: \(error.localizedDescription)")
      }
      
    }

    deinit {
        timer?.invalidate()
    }

}

