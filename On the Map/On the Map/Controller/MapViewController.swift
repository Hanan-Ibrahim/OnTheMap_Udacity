//
//  MapViewController.swift
//  On the Map
//
//  Created by Hanoudi on 5/10/20.
//  Copyright © 2020 Hanoudi. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    //  MARK:- Variables
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    var newAnnotation = MKPointAnnotation()
    
    @IBAction func addPin(_ sender: Any) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PinViewController") as! PinViewController
        self.present(viewController, animated: true, completion: nil)
    }
    @IBAction func logOutButton(_ sender: Any) {
        // Empty the student Infromation list
        
        //Post a Notification that the app is logging out so observers can unsubscribe
        //NotificationCenter.default.post(name: Notification.Name(rawValue: "logout"), object: nil)
        UdacityStudent.logout(completion: {
            StudentsInformation.data = []
             let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
             self.present(viewController, animated: true, completion: nil)
            
        }) }
    //  MARK:- MapView Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mapView.removeAnnotations(self.mapView.annotations)
        mapView.delegate = self
        addressTextField.delegate = self
        subscribe()
        setupMap()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    
    @IBAction func submit(_ sender: Any) {
                     let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PinViewController") as! PinViewController
        self.present(viewController, animated: true, completion: nil)
        
    }
    // Unwind Segue goes back to controller that was previously seen
    @IBAction func unwindToTab(unwindSegue: UIStoryboardSegue) {
        if let addPinViewController = unwindSegue.source as? PinViewController {
            guard addPinViewController.placeSelected != "" else{
                return
            }
            
            // Update the Current Student Location Instance
            StudentLocation.instance = StudentLocation.init(uniqueKey: "", firstName: "", lastName: "", mapString: addPinViewController.placeSelected, mediaURL: "", latitude: 0, longitude: 0)
            
            self.showLocationOnMap()
        }
    }
    
    // MARK: Check if location is valid and zoom in on it
    func showLocationOnMap(){
        self.activityIndicator.startAnimating()
        print("Animating")
        // MARK: Geocode the Location user entered
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = StudentLocation.instance?.mapString
        let search = MKLocalSearch(request: searchRequest)

        // If it doesn't exist display an error message
        search.start { response, error in
            print("Stop Animating")
            self.activityIndicator.stopAnimating()
            guard let response = response else {
                self.displayErrorAlert(title: "Error", message: "Can't Find Location")
                return
            }
            
            
        for item in response.mapItems {
            if let mi = item as? MKMapItem {
                // zoom in on the location
                let span = MKCoordinateSpan(latitudeDelta: 0.9000, longitudeDelta: 0.9000)
                let coordinate = mi.placemark.location?.coordinate
                let region = MKCoordinateRegion(center: coordinate!, span: span)
                self.mapView.setRegion(region, animated: true)

                // Update the Student Location Instance with the coordinates
                StudentLocation.instance?.longitude = Float(coordinate!.longitude)
                StudentLocation.instance?.latitude = Float(coordinate!.latitude)
                
                // Show a new PinMarker on the Map
                self.newAnnotation.coordinate = coordinate!
                self.mapView.addAnnotation(self.newAnnotation)
                
                // Retrieve student infromation [ FirstName, LastName ]
                UdacityStudent.getUserData(completion: self.handleUserData)
                break
                }
            }
        }
    }
    
    func handleUserData(userData: UserData?, error: Error?){
        guard error == nil else{
            displayErrorAlert(title: "Error", message: "Can't retrieve account information")
            return
        }
        
        StudentLocation.instance?.firstName = userData!.firstName
        StudentLocation.instance?.lastName = userData!.lastName
    }
    // Save the URL and POST the New Student Location
    
    @IBAction func submitButtonTapped(_ sender: Any) {

        StudentLocation.instance?.mediaURL = addressTextField.text ?? ""
        UdacityStudent.postStudentLocation(studentLocation: StudentLocation.instance!){ error in
            
            guard error == nil else{
                self.displayErrorAlert(title:"Error", message: "Can't Post New Location")
                return
            }
            self.mapView.removeAnnotation(self.newAnnotation)
            self.newAnnotation.title = "\(StudentLocation.instance!.firstName) \(StudentLocation.instance!.lastName)"
            self.newAnnotation.subtitle = StudentLocation.instance!.mediaURL
            self.mapView.addAnnotation(self.newAnnotation)
        }
    }
    
}




extension MapViewController: MKMapViewDelegate, UITextFieldDelegate{

    func subscribe(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateStudentsInfromation(_:)), name: Notification.Name(rawValue: "updateStudentsInfromation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unsubscribe(_:)), name: Notification.Name(rawValue: "logout"), object: nil)
    }
    
    @objc func unsubscribe(_ notification: Notification){
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"updateStudentsInfromation"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"logout"), object: nil)
    }
    
    @objc func updateStudentsInfromation(_ notification: Notification) {
        setupMap()
        self.mapView.reloadInputViews()
    }
    
    func setupMap(){
        var annotations = [MKPointAnnotation]()
        
        for student in StudentsInformation.data {
            let lat = CLLocationDegrees(student.latitude)
            let long = CLLocationDegrees(student.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let first = student.firstName
            let last = student.lastName
            let mediaURL = student.mediaURL
            
            //create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // append the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        // add the annotations to the map.
        self.mapView.addAnnotations(annotations)
    }
    
   
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.tintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // Open MediaURL in default browser when pinAnnotationView tapped
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
            guard let urlString = view.annotation?.subtitle!, let url = URL(string: urlString) else{
                displayErrorAlert(title: "Error", message: "URL not valid or student did not provide it")
                return
            }
            
            UIApplication.shared.open(url, options: [:]) { success in
                guard success == true else{
                    self.displayErrorAlert(title: "Error", message: "URL not valid or student did not provide it")
                    return
                }
            }
        }
    }
    
   func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         textField.resignFirstResponder()
         return true
     }
     
     @objc func keyboardWillShow(_ notification:Notification) {
         if addressTextField.isFirstResponder && view.frame.origin.y == 0 {
             view.frame.origin.y -= getKeyboardHeight(notification)
         }

     }
     
     func subscribeToKeyboardNotifications() {
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification , object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
     }
     
     @objc func keyboardWillHide(_ notification:Notification) {
         if addressTextField.isFirstResponder && view.frame.origin.y != 0  {
             view.frame.origin.y = 0
         }
     }
     
     func unsubscribeFromKeyboardNotifications() {
         NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
         NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
     }
     
     func getKeyboardHeight(_ notification:Notification) -> CGFloat {
         
         let userInfo = notification.userInfo
         let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
         return keyboardSize.cgRectValue.height
     }
    
}
