//
//  Login+CoreDataProperties.swift
//  StudyApp
//
//  Created by 장태현 on 2020/09/27.
//  Copyright © 2020 장태현. All rights reserved.
//
//

import Foundation
import CoreData


extension Login {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Login> {
        return NSFetchRequest<Login>(entityName: "Login")
    }

    @NSManaged public var login_type: String?
    @NSManaged public var user_email: String?
    @NSManaged public var user_pw: String?
    @NSManaged public var group_id: Int16
    @NSManaged public var user_phone: String?

}
