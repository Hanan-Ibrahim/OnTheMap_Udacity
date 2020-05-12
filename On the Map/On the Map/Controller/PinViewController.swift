//
//  PinViewController.swift
//  On the Map
//
//  Created by Hanoudi on 5/10/20.
//  Copyright © 2020 Hanoudi. All rights reserved.
//


import UIKit

class PinViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet var findButton: UIButton!
    var placeSelected: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addressTextField.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // Save entered Text and return to MapViewController
    @IBAction func returnToTabController(_ sender: Any) {
        placeSelected = addressTextField.text ?? ""
  //     let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabViewController") as! TabViewController
//       self.present(viewController, animated: true, completion: nil)

        self.performSegue(withIdentifier: "unwindToTabController", sender: self)
    }
}
