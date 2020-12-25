//
//  GithubCall+CoreDataProperties.swift
//  Tortuga
//
//  Created by admin on 2020/12/25.
//
//

import Foundation
import CoreData


extension GithubCall {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GithubCall> {
        return NSFetchRequest<GithubCall>(entityName: "GithubCall")
    }

    @NSManaged public var url: String?
    @NSManaged public var response: Data?
    @NSManaged public var ctime: Date?
    @NSManaged public var error: String?

}

extension GithubCall : Identifiable {

}
