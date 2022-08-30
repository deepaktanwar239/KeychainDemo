//
//  KeychainHelper.swift
//  KeychainDemo
//
//  Created by Arcind on 25/08/22.
//

import Foundation
import Security

struct KeychainHelper {
    // MARK: Types
    
    enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unexpectedItemData
        case unhandledError(status: OSStatus)
    }
    
    // MARK: Properties
    
    let service: String
    private(set) var account: String
    
    let accessGroup: String?
    
    // MARK: Intialization
    
    init(service: String, account: String, accessGroup: String? = nil) {
        self.service = service
        self.account = account
        self.accessGroup = accessGroup
    }
    
    // MARK: Keychain access
     func readItem() throws -> String {
         /*
          Build a query to find the item that matches the service, account and
          access group.
          */
         var query = KeychainHelper.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
         query[kSecMatchLimit as String] = kSecMatchLimitOne
         query[kSecReturnData as String] = kCFBooleanTrue
         
            var queryResult: AnyObject?
            let status = SecItemCopyMatching(
                query as CFDictionary,
                &queryResult
            )
            guard status != errSecItemNotFound else {
                throw KeychainError.noPassword
            }
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedItemData
        }
        guard let password = queryResult as? Data, let result = String(data: password, encoding: String.Encoding.utf8) else {
            throw KeychainError.unhandledError(status: status)
        }
        return result
    }
    func readItemArray() throws -> DataModel? {
        /*
         Build a query to find the item that matches the service, account and
         access group.
         */
            var query = KeychainHelper.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            query[kSecMatchLimit as String] = kSecMatchLimitOne
            query[kSecReturnData as String] = kCFBooleanTrue
            
               var queryResult: AnyObject?
               let status = SecItemCopyMatching(
                   query as CFDictionary,
                   &queryResult
               )
               guard status != errSecItemNotFound else {
                   throw KeychainError.noPassword
               }
           guard status == errSecSuccess else {
               throw KeychainError.unexpectedItemData
           }
           guard let password = queryResult as? Data else {
               throw KeychainError.unhandledError(status: status)
           }
            let result = try JSONDecoder().decode(DataModel.self, from: password)
            return result
      }
    
   
    
      func saveItem(_ password: DataModel) throws {
         // Encode the password into an Data object.
        
        let encodedPassword = try JSONEncoder().encode(password)
        do {
         // Check for an existing item in the keychain.
             try _ = readItemArray()
             
             // Update the existing item with the new password.
             var attributesToUpdate = [String: AnyObject]()
             attributesToUpdate[kSecValueData as String] = encodedPassword as AnyObject?
             
             let query = KeychainHelper.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
             let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
             
             // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
             } catch KeychainError.noPassword {
                 /*
                  No password was found in the keychain. Create a dictionary to save
                  as a new keychain item.
                  */
                 var newItem = KeychainHelper.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
                 newItem[kSecValueData as String] = encodedPassword as AnyObject?
                 
                 // Add a the new item to the keychain.
                 let status = SecItemAdd(newItem as CFDictionary, nil)
                 
                 // Throw an error if an unexpected status was returned.
                 guard status == noErr else { throw KeychainError.unhandledError(status: status) }
             }
        }
            func deleteItem() throws {
                // Delete the existing item from the keychain.
                let query = KeychainHelper.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
                let status = SecItemDelete(query as CFDictionary)
                // Throw an error if an unexpected status was returned.
                guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
            }
    
        // MARK: Convenience
         private static func keychainQuery(withService service: String, account: String? = nil, accessGroup: String? = nil) -> [String: AnyObject] {
            var query = [String: AnyObject]()
            query[kSecClass as String] = kSecClassGenericPassword
            query[kSecAttrService as String] = service as AnyObject?
            
            if let account = account {
                query[kSecAttrAccount as String] = account as AnyObject?
            }
            
    //        if let accessGroup = accessGroup {
    //           query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
    //        }
            
            return query
        }
       
}
