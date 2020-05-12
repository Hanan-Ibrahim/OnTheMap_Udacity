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

        if( StudentsInformation.data.isEmpty){
            loadStudentInformation()
        }
    }
    
    func handleStudentsInformation(error: Error?){
        guard error == nil else{
            showErrorAndReloadData(message: error?.localizedDescription ?? "Error")
            return
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateStudentsInfromation"), object: nil)
    }
    
    @objc func logout(){
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        UdacityStudent.logout(completion: handlelogout)
    }
    
    func handlelogout(){
    
        StudentsInformation.data = []
        NotificationCenter.default.post(name: Notification.Name(rawValue: "logout"), object: nil)
                UdacityStudent.logout(completion: handlelogout)
        navigationController?.popToRootViewController(animated: true)
    }
    
    func showErrorAndReloadData(message: String){
        let alertController = UIAlertController(title: "Fetching Students Information Failed", message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Reload", style: .default) { alertAction in
            self.loadStudentInformation()
        }
        alertController.addAction(okButton)
        present(alertController, animated: true, completion: nil)
    }
    
}



    



