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

        
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var addressTextField: UITextField!
    
    @IBOutlet var submitButton: UIButton!

    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    var newAnnotation = MKPointAnnotation()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI()
        self.mapView.removeAnnotations(self.mapView.annotations)
        mapView.delegate = self
        addressTextField.delegate = self
        subscribe()
        setupMap()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    // MARK: Unwind Segue Triggered when user return from AddPinViewController
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
    
    // MARK: If the student information can't be found ignore posting the new Pin Location
    func handleUserData(userData: UserData?, error: Error?){
        guard error == nil else{
            displayErrorAlert(title: "Error", message: "Can't retrieve account information")
            return
        }
        
        StudentLocation.instance?.firstName = userData!.firstName
        StudentLocation.instance?.lastName = userData!.lastName
        
        // Disable Navigationbar and Tabbar when waiting for the user to enter URL
        enteringURL(true)
    }
    
    // MARK: Save the URL and POST the New Student Location
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        // Enable Navigationbar and Tabbar
        enteringURL(false)
        
        StudentLocation.instance?.mediaURL = addressTextField.text ?? ""
        
        UdacityStudent.postStudentLocation(studentLocation: StudentLocation.instance!){ error in
            
            guard error == nil else{
                self.displayErrorAlert(title:"Error", message: "Can't Post New Location")
                return
            }
            
            
            // Display new PinMarker with the URL
            self.mapView.removeAnnotation(self.newAnnotation)
            self.newAnnotation.title = "\(StudentLocation.instance!.firstName) \(StudentLocation.instance!.lastName)"
            self.newAnnotation.subtitle = StudentLocation.instance!.mediaURL
            self.mapView.addAnnotation(self.newAnnotation)
        }
    }
}


extension MapViewController: MKMapViewDelegate, UITextFieldDelegate{

    func configureUI(){
        addressTextField.isHidden = true
        // Change corners to be round
        addressTextField.layer.borderWidth = 2.0
        addressTextField.layer.masksToBounds = true
        addressTextField.layer.borderColor =  UIColor(white: 1.0, alpha: 0).cgColor
        addressTextField.layer.backgroundColor =  UIColor(white: 0, alpha: 0.2).cgColor
        
        
        submitButton.layer.cornerRadius = 25
        submitButton.layer.borderWidth = 2.0
        submitButton.layer.masksToBounds = true
        submitButton.layer.borderColor =  UIColor(white: 1.0, alpha: 0).cgColor
        
    
    }
    
    // MARK: Hides KeyBoard after Returning from Editing Text Field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // MARK: Disable Navigationbar and Tabbar when waiting for the user to enter URL
    func enteringURL(_ state: Bool){
        if state{
            self.addressTextField.isHidden = false
            navigationController?.isNavigationBarHidden = true
            tabBarController?.tabBar.isHidden = true
            
        }else{
            self.addressTextField.isHidden = true
            navigationController?.isNavigationBarHidden = false
            tabBarController?.tabBar.isHidden = false;
            
        }
    }
    
    // MARK: Subscribe to tabController notifications
    func subscribe(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateStudentsInfromation(_:)), name: Notification.Name(rawValue: "updateStudentsInfromation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unsubscribe(_:)), name: Notification.Name(rawValue: "logout"), object: nil)
    }
    
    // MARK: Unsubscribe to tabController notifications
    @objc func unsubscribe(_ notification: Notification){
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"updateStudentsInfromation"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"logout"), object: nil)
    }
    
    // MARK: Update User Student Information on the Map
    @objc func updateStudentsInfromation(_ notification: Notification) {
        setupMap()
        self.mapView.reloadInputViews()
    }
    
    // MARK: Extract the information for every student and update annotation list
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
    
    // MARK: Update and Display PinMarker
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
    
}
