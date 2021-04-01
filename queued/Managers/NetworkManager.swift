//
//  NetworkManager.swift
//  queued
//
//  Created by Ted Bennett on 27/03/2021.
//

import Foundation

class NetworkManager {
    static var shared = NetworkManager()
    
    let baseUrl = "https://queued1.herokuapp.com"
    
    private init() { }
    
    func request<Object: Decodable>(url: URLRequest, completion: @escaping (Object?) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil, let data = data else {
                print(error.debugDescription)
                completion(nil)
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-DD'T'HH:mm:ss.SSS'Z'"
            decoder.dateDecodingStrategy = .formatted(formatter)
            
            do {
                let decoded = try decoder.decode(Object.self, from: data)
                completion(decoded)
            } catch let parseError {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                    print(json)
                }
                print(parseError)
                completion(nil)
            }
        }.resume()
    }
    
    func requestWithoutBody(url: URLRequest, completion: @escaping (Bool) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print(error.debugDescription)
                completion(false)
                return
            }
            completion(true)
        }.resume()
    }
    
    
    // MARK: Session
    func createSession(name: String, completion: @escaping (Session?) -> Void) {
        guard let userId = UserManager.shared.getId() else {
            completion(nil)
            return
        }
        
        let url = URL(string:  "\(baseUrl)/sessions")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let body: [String : String] = ["name": name, "host": userId]
        if let data = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed) {
            urlRequest.httpBody = data
        }
        request(url: urlRequest) { completion($0) }
        
    }
    
    func getSession(id: String, completion:  @escaping (Session?) -> Void) {
        let url = URL(string: "\(baseUrl)/sessions/\(id)")!
        request(url: URLRequest(url: url)) { completion($0) }
    }
    
    func getSession(key: String, completion:  @escaping (Session?) -> Void) {
        let url = URL(string: "\(baseUrl)/sessions/key/\(key)")!
        request(url: URLRequest(url: url)) { completion($0) }
        
    }
    
    func joinSession(id: String, completion:  @escaping (Session?) -> Void) {
        guard let userId = UserManager.shared.getId() else {
            completion(nil)
            return
        }
        let url = URL(string: "\(baseUrl)/sessions/\(id)/members/\(userId)")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        request(url: urlRequest) { completion($0) }
    }
    
    func leaveSession(id: String, completion: @escaping (Bool) -> Void) {
        guard let userId = UserManager.shared.getId() else {
            completion(false)
            return
        }
        let url = URL(string: "\(baseUrl)/sessions/\(id)/members/\(userId)")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        
        requestWithoutBody(url: urlRequest) { completion($0) }
    }
    
    func addSongToQueue(_ song: Song, sessionId: String, completion: @escaping (Bool) -> Void) {
        guard let userId = UserManager.shared.getId() else {
            completion(false)
            return
        }
        
        let body = [
            "id": song.id,
            "name": song.name,
            "artist": song.artist,
            "album": song.album,
            "image_url": song.imageUrl,
            "queued_by": userId
        ]
        
        let url = URL(string: "\(baseUrl)/sessions/\(sessionId)")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if let data = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed) {
            urlRequest.httpBody = data
        }
        requestWithoutBody(url: urlRequest) { completion($0) }
    }
    
    func deleteSession(id: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "\(baseUrl)/sessions/\(id)")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        
        requestWithoutBody(url: urlRequest) { completion($0) }
    }
    
    // MARK: User
    func createUser(completion: @escaping (String?) -> Void) {
        let url = URL(string: "\(baseUrl)/users")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        request(url: urlRequest) { completion($0) }
    }
    
    func getUser(id: String, completion: @escaping (User?) -> Void) {
        let url = URL(string: "\(baseUrl)/users/\(id)")!
        request(url: URLRequest(url: url)) { completion($0) }
    }
    
    func updateUser(name: String, imageUrl: String?, completion: @escaping (Bool) -> Void) {
        guard let userId = UserManager.shared.getId() else {
            completion(false)
            return
        }
        var body = [String: String]()
        
        
        body["name"] = name
        if let imageUrl = imageUrl {
            body["image_url"] = imageUrl
        }
        
        let url = URL(string: "\(baseUrl)/users/\(userId)")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if let data = try? JSONSerialization.data(withJSONObject: body) {
            urlRequest.httpBody = data
        }
        
        requestWithoutBody(url: urlRequest) { completion($0) }
    }
    
    // MARK: Spotify Management
    
    func authoriseWithSpotify(code: String, completion: @escaping (Bool) -> Void) {
        guard let userId = UserManager.shared.getId() else {
            completion(false)
            return
        }
        let url = URL(string: "\(baseUrl)/users/\(userId)/authoriseWithSpotify")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let body = ["code": code]
        if let data = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed) {
            urlRequest.httpBody = data
        }
        
        requestWithoutBody(url: urlRequest) { completion($0) }
    }
}
