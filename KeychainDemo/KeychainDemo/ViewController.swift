//
//  ViewController.swift
//  KeychainDemo
//
//  Created by Arcind on 25/08/22.
//

import UIKit

struct KeychainConfiguration {
    static let serviceName = "Keychain_Demo_Service_Save_Encode_Data"
    static let accountName = "KeychainDemo"
    //static let accessGroup = "deepak.KeychainDemo"
}

struct DataModel : Codable {
    
    let firstname,lastname,email,id,fullname,password : String

}

class ViewController: UIViewController {
       
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var userid: UILabel!
    @IBOutlet weak var password: UILabel!
    
    let data = DataModel(firstname: "Test", lastname: "Test", email: "test@gmail.com", id: "123456789", fullname: "Test Test", password: "Pass@1234")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* If you want to delete keychain data call delete function*/
         //self.deleteKeychainData()
        
        // if data already stored into keychain
        if let userData = self.getDataFromKeychain(){
            self.showKeyChainData(userData)
        }else{ //store data into keychain
            if(self.saveDataInKeychain(data)){
                if let userData = self.getDataFromKeychain(){
                    self.showKeyChainData(userData)
                }
            }
        }
    
    }
  
    
    func showKeyChainData(_ userData : DataModel?){
        if let data = userData {
            self.firstName.text = data.firstname
            self.lastName.text = data.lastname
            self.email.text = data.email
            self.userid.text = data.id
            self.password.text = data.password
        }
    }
    
}

extension  ViewController {
    
    private func saveDataInKeychain(_ userData: DataModel) -> Bool {
        do {
            try KeychainHelper(service: KeychainConfiguration.serviceName, account:KeychainConfiguration.accountName).saveItem(userData)
            return true
        } catch {
            self.showAlert(msg: "Something went wrong while saving data into keychain")
            return false
            
        }
    }
    
    private func getDataFromKeychain() -> DataModel? {
        
        do {
            let data = try KeychainHelper(service: KeychainConfiguration.serviceName, account:KeychainConfiguration.accountName).readItemArray()
            return data
        } catch KeychainHelper.KeychainError.unexpectedItemData {
            print(KeychainHelper.KeychainError.unexpectedItemData )
        } catch (KeychainHelper.KeychainError.unhandledError){
            print(KeychainHelper.KeychainError.unhandledError)
        }catch (KeychainHelper.KeychainError.noPassword){
            print(KeychainHelper.KeychainError.noPassword)
        }
        catch {}
        self.showAlert(msg: "Something went wrong while getting data from keychain")
        return nil
    }
    
    private func deleteKeychainData(){
        do {
            try KeychainHelper(service: KeychainConfiguration.serviceName, account:KeychainConfiguration.accountName).deleteItem()
        } catch  {
            print("Error while deleting keychain  data")
        }

        
    }
}

extension ViewController {
    func showAlert(msg : String){
        let alert = UIAlertController(title: "", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
}
