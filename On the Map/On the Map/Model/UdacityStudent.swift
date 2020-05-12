//
//  UdacityStudent.swift
//  On the Map
//
//  Created by Hanoudi on 5/11/20.
//  Copyright © 2020 Hanoudi. All rights reserved.
//

import Foundation


class UdacityStudent{
    
    enum Endpoints{
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case createSessionId
        case deleteSession
        case getUserData
        case getStudentsInforamtion
        case postStudentLocation
        
        var stringValue: String{
            switch self{
            case .createSessionId, .deleteSession: return Endpoints.base + "/session"
            case .getUserData: return Endpoints.base + "/users/\(Auth.accountId)"
            case .getStudentsInforamtion: return Endpoints.base + "/StudentLocation?order=-updatedAt?limit=-100"
            case .postStudentLocation: return Endpoints.base + "/StudentLocation"
            }
        }
        
        var url: URL{
            return URL(string: stringValue)!
        }
    }
    
    struct Auth {
        static var accountId = ""
        static var sessionId = ""
    }
    
    class func login(userData: LoginData, completion: @escaping (Bool, Error?)->Void){
        
        var request = URLRequest(url: Endpoints.createSessionId.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // Encode userData to JSON and add it as Body
        let encoder = JSONEncoder()
        let body = try! encoder.encode(LoginRequest(udacity: userData))
        request.httpBody = body
        
        // Post SessionID Request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else{
                DispatchQueue.main.async {
                    completion(false,error)
                }
                return
            }
            
            // Result need to remove first 5 character to be able to JSON Decode it
            let newData = data.subdata(in: (5..<data.count))
            let decoder = JSONDecoder()
            do{
                // Parse it in LoginResponse
                let userData = try decoder.decode(LoginResponse.self, from: newData)
                Auth.accountId = userData.account.key
                Auth.sessionId = userData.session.id
                
                DispatchQueue.main.async {
                    completion(userData.account.registered,nil)
                }
            }catch{
                do{
                    // Parse it in ErrorResponse
                    let error = try decoder.decode(ErrorResponse.self, from: newData)
                    DispatchQueue.main.async {
                        completion(false,error)
                    }
                }catch{
                    DispatchQueue.main.async {
                        completion(false,error)
                    }
                }
            }
        }
        task.resume()
    }
    
    
    class func logout(completion: @escaping () -> Void){
        var request = URLRequest(url: Endpoints.deleteSession.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        // Delete Session Request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                completion()
            }
        }
        task.resume()
    }
    
    class func getUserData(completion: @escaping (UserData?, Error?)-> Void){
        var request = URLRequest(url: Endpoints.getUserData.url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // GetUserData Request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else{return}
            
            // Result need to remove first 5 character to be able to JSON Decode it
            let newData = data.subdata(in: (5..<data.count))
            
            do{
                let decoder = JSONDecoder()
                let userData = try decoder.decode(UserData.self, from: newData)
                DispatchQueue.main.async {
                     completion(userData, nil)
                }
            }catch{
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    class func getStudentsInformation(completion: @escaping (Error?)->Void){
        let request = URLRequest(url: Endpoints.getStudentsInforamtion.url)
        // GetStudentInformation Request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
        
            guard let data = data else{
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do{
                let studentsInfo = try decoder.decode(StudentsInfoResponse.self, from: data)
                StudentsInformation.data = studentsInfo.results
                DispatchQueue.main.async {
                    completion(nil)
                }
            }catch{
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
        task.resume()
    }
    
    class func postStudentLocation(studentLocation: StudentLocation, completion: @escaping (Error?)-> Void){
        var request = URLRequest(url: Endpoints.postStudentLocation.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encode StudentLocation to JSON and add it as Body
        let encoder = JSONEncoder()
        let body = try! encoder.encode(studentLocation)
        request.httpBody = body
        
        // Post StudentLocation Request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else{
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(nil)
            }
        }
        task.resume()
    }
}
