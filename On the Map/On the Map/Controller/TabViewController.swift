//
//  TabViewController.swift
//  On the Map
//
//  Created by Hanoudi on 5/11/20.
//  Copyright © 2020 Hanoudi. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {
    // MARK:- UI methods
    
    func loadStudentInformation(){
        UdacityStudent.getStudentsInformation(completion: handleStudentsInformation)
    }
    
    // MARK:- TabView Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //configureUI()
        // Load students details if it doesn't exist yet
        if( StudentsInformation.data.isEmpty){
            loadStudentInformation()
        }
    }
    
    /*
    func configureUI(){
        navigationController?.isNavigationBarHidden = false
        let logoutBarButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logout))
        
        let addBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin.png"), style:.plain, target: self, action:  #selector(addMarker))
        
        
        navigationItem.leftBarButtonItem  = logoutBarButtonItem
        navigationItem.rightBarButtonItem = addBarButtonItem
        navigationItem.title = "On The Map"
    }
   */
 
    // MARK: Notify user if error occured
    func handleStudentsInformation(error: Error?){
        guard error == nil else{
            showErrorAndReloadData(message: error?.localizedDescription ?? "Error")
            return
        }
        
        //Post a Notification that the StudentInfromation Array has been updated so observers can take requried actions accordingly
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateStudentsInfromation"), object: nil)
    }
    
    @objc func logout(){
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        UdacityStudent.logout(completion: handlelogout)
    }
    
    // MARK: Return to login screen
    func handlelogout(){
        // Empty the student Infromation list
        StudentsInformation.data = []
        //Post a Notification that the app is logging out so observers can unsubscribe
        NotificationCenter.default.post(name: Notification.Name(rawValue: "logout"), object: nil)
        navigationController?.popToRootViewController(animated: true)
    }
    


    // MARK: Display Error Messages to the User and Reloads Students Locations
    func showErrorAndReloadData(message: String){
        let alertController = UIAlertController(title: "Fetching Students Information Failed", message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Reload", style: .default) { alertAction in
            self.loadStudentInformation()
        }
        alertController.addAction(okButton)
        present(alertController, animated: true, completion: nil)
    }
}
