//
//  CoreDataManager.swift
//  StudyApp
//
//  Created by 장태현 on 2020/09/26.
//  Copyright © 2020 장태현. All rights reserved.
//

import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    lazy var context = appDelegate?.persistentContainer.viewContext
    
    let modelName: String = "Login"
    
    func getLogin(ascending: Bool = false) -> [Login] {
        var models: [Login] = [Login]()
        
        if let context = context {
            let idSort: NSSortDescriptor = NSSortDescriptor(key: "user_email", ascending: ascending)
            let fetchRequest: NSFetchRequest<NSManagedObject>
                = NSFetchRequest<NSManagedObject>(entityName: modelName)
            fetchRequest.sortDescriptors = [idSort]
            
            do {
                if let fetchResult: [Login] = try context.fetch(fetchRequest) as? [Login] {
                    models = fetchResult
                }
            } catch let error as NSError {
                print("Could not fetch🥺: \(error), \(error.userInfo)")
            }
        }
        return models
    }
    
    func saveLogin(userEmail: String, userPw: String,
                   loginType: String, groupId: Int16, userPhone: String, onSuccess: @escaping ((Bool) -> Void)) {
        if let context = context,
            let entity: NSEntityDescription
            = NSEntityDescription.entity(forEntityName: modelName, in: context) {
            
            if let login: Login = NSManagedObject(entity: entity, insertInto: context) as? Login {
                login.user_email = userEmail
                login.user_pw = userPw
                login.login_type = loginType
                login.group_id = groupId
                login.user_phone = userPhone
                
                contextSave { success in
                    onSuccess(success)
                }
            }
        }
    }
    
    func deleteLogin(userEmail: String, onSuccess: @escaping ((Bool) -> Void)) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = filteredRequest(userEmail: userEmail)
        
        do {
            if let results: [Login] = try context?.fetch(fetchRequest) as? [Login] {
                if results.count != 0 {
                    context?.delete(results[0])
                }
            }
        } catch let error as NSError {
            print("Could not fatch🥺: \(error), \(error.userInfo)")
            onSuccess(false)
        }
        
        contextSave { success in
            onSuccess(success)
        }
    }
}

extension CoreDataManager {
    fileprivate func filteredRequest(userEmail: String) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
            = NSFetchRequest<NSFetchRequestResult>(entityName: modelName)
        fetchRequest.predicate = NSPredicate(format: "user_email = %@", NSString(string: userEmail))
        return fetchRequest
    }
    
    fileprivate func contextSave(onSuccess: ((Bool) -> Void)) {
        do {
            try context?.save()
            onSuccess(true)
        } catch let error as NSError {
            print("Could not save🥶: \(error), \(error.userInfo)")
            onSuccess(false)
        }
    }
}
