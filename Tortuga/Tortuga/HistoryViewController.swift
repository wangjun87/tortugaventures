//
//  HistoryViewController.swift
//  Tortuga
//
//  Created by admin on 2020/12/25.
//

import UIKit
import CoreData
class HistoryViewController: UIViewController {

    @IBOutlet weak var historyTableView: UITableView!
    var historyItems: [GithubCall] = []
    private let refreshControl = UIRefreshControl()
    
    public var updateAction: (() -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        historyTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(HistoryViewController.refresh(sender:)), for: .valueChanged)
        historyTableView.register(UINib.init(nibName: "HistoryCell", bundle: nil), forCellReuseIdentifier: "HistoryCell")
        self.updateAction = {
            [weak self] in
            self!.showAlert()
        }
        getCacheData()
    }
    
    
    // MARK: - show new api call alert
    func showAlert() {
        let alert = UIAlertController(title: "new call", message: "This is a new call.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
        NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)

    }

    // MARK: - to get cached data from local database
    func getCacheData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GithubCall")
        fetchRequest.fetchLimit = 10
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "ctime", ascending: false)]
        DispatchQueue.main.async {
            [weak self] in
            do {
                self!.historyItems = try managedContext.fetch(fetchRequest) as? [GithubCall] ?? []
                self!.historyTableView.reloadData()
            } catch let error as NSError {
              print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
    @objc func refresh(sender: UIRefreshControl) {
        getCacheData()
        sender.endRefreshing()
    }

}

extension HistoryViewController:UITableViewDelegate,UITableViewDataSource{
    //MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64;
    }

    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
        configureCell(cell: cell, forRowAt: indexPath)
        return cell
    }
    
    func configureCell(cell: HistoryCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            cell.backgroundColor = UIColor.orange
        }else{
            cell.backgroundColor = UIColor.white
        }
        let historyItem = historyItems[indexPath.row]
        cell.itemL.text = historyItem.url
        cell.timeL.text = historyItem.ctime?.description
    }
}
