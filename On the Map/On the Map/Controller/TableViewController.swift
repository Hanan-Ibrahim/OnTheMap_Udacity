//
//  TableViewController.swift
//  On the Map
//
//  Created by Hanoudi on 5/10/20.
//  Copyright © 2020 Hanoudi. All rights reserved.
//


import UIKit

class TableViewController: UITableViewController {
    
    // MARK:- UI Methods
    @IBAction func addPin(_ sender: Any) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PinViewController") as! PinViewController
        self.present(viewController, animated: true, completion: nil)
        
    }
    @objc func updateStudentsInfromation(_ notification: Notification) {
        // DispatchQueue.main.async is an object that manages the execution
        // of tasks serially or concurrently on your app's main thread
        // DispatchQueue.main.asysn{ doSomething() } tells GCD to access main
        // thread and perform the block doSomething aysnchronously
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func URLunavailable() {
        self.displayErrorAlert(title: "URL could not be opened.",message: "URL is either not valid or unavailable.")
    }
    
    // MARK:- TableView LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToStudentsInformationNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
  
    // MARK:- TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentsInformation.data.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell")!
        cell.textLabel?.text = StudentsInformation.data[indexPath.row].firstName +  StudentsInformation.data[indexPath.row].lastName
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = URL(string: StudentsInformation.data[indexPath.row].mediaURL)
            else {
                URLunavailable()
            return
        }
        
        UIApplication.shared.open(url, options: [:]) { success in
            guard success == true
                else {
                    self.URLunavailable()
                return
             }
          }
       }
    
    func subscribeToStudentsInformationNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateStudentsInfromation(_:)), name: Notification.Name(rawValue: "updateStudentsInfromation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unsubscribeFromStudentsInformationNotifications(_:)), name: Notification.Name(rawValue: "logout"), object: nil)
    }
    
    @objc func unsubscribeFromStudentsInformationNotifications(_ notification: Notification){
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"updateStudentsInfromation"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"logout"), object: nil)
    }
}
