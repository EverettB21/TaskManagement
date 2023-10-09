//
//  Task+CoreDataProperties.swift
//  TaskManagement
//
//  Created by Everett Brothers on 10/8/23.
//
//

import Foundation
import CoreData
import UIKit

extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var name: String?
    @NSManaged public var priority: Double
    @NSManaged public var body: String?

}

extension Task : Identifiable {

}
