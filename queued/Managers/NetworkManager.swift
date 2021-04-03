//
//  NetworkManager.swift
//  queued
//
//  Created by Ted Bennett on 27/03/2021.
//

import Foundation
import Starscream

class NetworkManager {
    static var shared = NetworkManager()
    
    private let baseUrl = "https://queued1.herokuapp.com"
    private let wsUrl = "ws://queued1.herokuapp.com"
    private var socket: WebSocket?
    var isConnected = false
    
    private init() { }
    
    private func request<Object: Decodable>(url: URLRequest, completion: @escaping (Object?) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil, let data = data else {
                print(error.debugDescription)
                completion(nil)
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
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
    
    private func requestWithoutResponse(url: URLRequest, completion: @escaping (Bool) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print(error.debugDescription)
                completion(false)
                return
            }
            if let response = response as? HTTPURLResponse {
                completion(response.statusCode == 200)
            } else {
                completion(false)
            }
            
            
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
    
    func updateSession(id: String, name: String, completion: @escaping (Session?) -> Void) {
        var body = [String: String]()
        
        body["name"] = name
        
        let url = URL(string: "\(baseUrl)/sessions/\(id)")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if let data = try? JSONSerialization.data(withJSONObject: body) {
            urlRequest.httpBody = data
        }
        
        request(url: urlRequest) { completion($0) }
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
        
        requestWithoutResponse(url: urlRequest) { completion($0) }
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
        let url = URL(string: "\(baseUrl)/sessions/\(sessionId)/queue")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if let data = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed) {
            urlRequest.httpBody = data
        }
        requestWithoutResponse(url: urlRequest) { completion($0) }
    }
    
    func listenToSession(id: String, connectionChanged: @escaping (Bool) -> Void, sessionChanged: @escaping (Session?) -> Void) {
        var request = URLRequest(url: URL(string: wsUrl)!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket?.connect()
        socket?.onEvent = { event in
            switch event {
                case .connected(let headers):
                    connectionChanged(true)
                    let response = ["sessionId": id, "type": "join"]
                    if let data = try? JSONSerialization.data(withJSONObject: response) {
                        self.socket?.write(data: data)
                    }
                    print("websocket is connected: \(headers)")
                case .disconnected(let reason, let code):
                    connectionChanged(false)
                    print("websocket is disconnected: \(reason) with code: \(code)")
                case .text(let string):
                    print("Received text: \(string)")
                    guard let data = string.data(using: .utf8) else { sessionChanged(nil)
                        return
                    }
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    if let session = try? decoder.decode(Session.self, from: data) {
                        sessionChanged(session)
                    }
                case .cancelled:
                    connectionChanged(false)
                case .error(let error):
                    print("Websocket error: \(error.debugDescription)")
                    connectionChanged(false)
                default:
                    break
            }
        }
    }
    
    func stopListeningToSession() {
        socket?.disconnect()
    }
    
    func deleteSession(id: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "\(baseUrl)/sessions/\(id)")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        
        requestWithoutResponse(url: urlRequest) { completion($0) }
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
        
        requestWithoutResponse(url: urlRequest) { completion($0) }
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
        
        requestWithoutResponse(url: urlRequest) { completion($0) }
    }
    
    func logoutFromSpotify(completion: @escaping (Bool) -> Void) {
        guard let userId = UserManager.shared.getId() else {
            completion(false)
            return
        }
        
        let url = URL(string: "\(baseUrl)/users/\(userId)/logoutFromSpotify")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        requestWithoutResponse(url: urlRequest) { completion($0) }
    }
}
