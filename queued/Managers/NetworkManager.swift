//
//  NetworkManager.swift
//  queued
//
//  Created by Ted Bennett on 27/03/2021.
//

import Foundation

class NetworkManager {
    static var shared = NetworkManager()
    
    private let baseUrl = "https://api.kude.app"
    private let wsUrl = "wss://ws.kude.app"
    //private var socket: WebSocket?
    var isConnected = false
    
    private init() { }
    
    private func request<Object: Decodable>(url: URLRequest, completion: @escaping (Object?) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil, let data = data else {
                print(error.debugDescription)
                completion(nil)
                return
            }
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                completion(nil)
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
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
                completion(response.statusCode <= 299)
            } else {
                
                completion(false)
            }
            
            
        }.resume()
    }
    
    // Must be called after checking user id
    private func createRequest(url: URL, method: HTTPMethod = .GET, body: [String:Any]? = nil) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if let body = body {
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        }
        
        return urlRequest
    }
    
    
    // MARK: Session
    func createSession(name: String, completion: @escaping (Session?) -> Void) {
        guard let userId = UserManager.shared.getId(), UserManager.shared.user?.host == true else {
            completion(nil)
            return
        }
        
        let url = URL(string:  "\(baseUrl)/sessions")!
        let urlRequest = createRequest(url: url, method: .POST, body: [
            "session_name": name,
            "user_id": userId
        ])
        request(url: urlRequest) { (id: String?) in
            guard let id = id else {
                completion(nil)
                return
            }
            self.getSession(id: id) { session in
                completion(session)
            }
        }
    }
    
    func getSession(id: String, completion:  @escaping (Session?) -> Void) {
        let url = URL(string: "\(baseUrl)/sessions/\(id)")!
        request(url: createRequest(url: url)) { completion($0) }
    }
    
    func getSession(key: String, completion:  @escaping (Session?) -> Void) {
        let url = URL(string: "\(baseUrl)/sessions/key/\(key)")!
        request(url: createRequest(url: url)) { completion($0) }
    }
    
    func updateSession(id: String, name: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "\(baseUrl)/sessions/\(id)")!
        let urlRequest = createRequest(url: url, method: .POST, body: ["session_name": name])
        requestWithoutResponse(url: urlRequest) { completion($0) }
    }
    
    
    func joinSession(id: String, completion:  @escaping (Session?) -> Void) {
        guard let userId = UserManager.shared.getId() else {
            completion(nil)
            return
        }
        let url = URL(string: "\(baseUrl)/sessions/\(id)/members")!
        let urlRequest = createRequest(url: url, method: .POST, body: ["user_id": userId])
        requestWithoutResponse(url: urlRequest) { success in
            if success {
                self.getSession(id: id) { session in
                    completion(session)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func leaveSession(id: String, completion: @escaping (Bool) -> Void) {
        guard let userId = UserManager.shared.getId() else {
            completion(false)
            return
        }
        
        self.stopListeningToSession()
        let url = URL(string: "\(baseUrl)/sessions/\(id)/members")!
        let urlRequest = createRequest(url: url, method: .DELETE, body: ["user_id": userId])
        requestWithoutResponse(url: urlRequest) {
            completion($0)
        }
    }
    
    func addSongToQueue(_ song: Song, sessionId: String, completion: @escaping (Bool) -> Void) {
        guard let userId = UserManager.shared.getId() else {
            completion(false)
            return
        }
        
        let body = [
            "song": [
                "id": song.id,
                "name": song.name,
                "artist": song.artist,
                "album": song.album,
                "image_url": song.imageUrl,
                "queued_by": userId
            ]
        ]
        let url = URL(string: "\(baseUrl)/sessions/\(sessionId)/queue")!
        requestWithoutResponse(url: createRequest(url: url, method: .POST, body: body)) {
            completion($0)
        }
    }
    
    func checkCurrentlyPlaying(id: String) {
        let url = URL(string: "\(baseUrl)/sessions/\(id)/nowPlaying")!
        
        requestWithoutResponse(url: createRequest(url: url, method: .POST)) { _ in }
    }
    
    func listenToSession(id: String, connectionChanged: @escaping (Bool) -> Void, sessionChanged: @escaping (Session?) -> Void) {
//        var request = URLRequest(url: URL(string: wsUrl)!)
//        request.timeoutInterval = 5
//        socket = WebSocket(request: request)
//        socket?.connect()
//        socket?.onEvent = { event in
//            switch event {
//                case .connected(let headers):
//                    connectionChanged(true)
//                    let response = ["session_id": id, "type": "join"]
//
//                    if let data = try? JSONSerialization.data(withJSONObject: response),
//                       let string  = String.init(data: data, encoding: String.Encoding.utf8) {
//                        self.socket?.write(string: string)
//                    }
//                    print("websocket is connected: \(headers)")
//                case .disconnected(let reason, let code):
//                    connectionChanged(false)
//                    print("websocket is disconnected: \(reason) with code: \(code)")
//                case .text(let string):
//                    print("Received text: \(string)")
//                    guard let data = string.data(using: .utf8) else { sessionChanged(nil)
//                        return
//                    }
//                    let decoder = JSONDecoder()
//                    decoder.keyDecodingStrategy = .convertFromSnakeCase
//                    if let session = try? decoder.decode(Session.self, from: data) {
//                        sessionChanged(session)
//                    } else if string == "session closed" {
//                        sessionChanged(nil)
//                    }
//                case .cancelled:
//                    connectionChanged(false)
//                case .error(let error):
//                    print("Websocket error: \(error.debugDescription)")
//                    connectionChanged(false)
//                default:
//                    break
//            }
//        }
    }
    
    func stopListeningToSession() {
        //socket?.disconnect()
    }
    
    func deleteSession(id: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "\(baseUrl)/sessions/\(id)")!
        self.stopListeningToSession()
        
        requestWithoutResponse(url: createRequest(url: url, method: .DELETE)) {
            completion($0)
        }
    }
    
    // MARK: User
    func createUser(completion: @escaping (String?) -> Void) {
        let url = URL(string: "\(baseUrl)/users")!
        let urlRequest = createRequest(url: url, method: .POST, body: ["user_name": ""])
        request(url: urlRequest) { completion($0) }
    }
    
    func getUser(id: String, completion: @escaping (User?) -> Void) {
        let url = URL(string: "\(baseUrl)/users/\(id)")!
        request(url: createRequest(url: url, method: .GET)) { completion($0) }
    }
    
    func updateUser(name: String, imageUrl: String?, completion: @escaping (Bool) -> Void) {
        guard let userId = UserManager.shared.getId() else {
            completion(false)
            return
        }
        let body = [
            "user_name": name,
            "image_url": imageUrl
        ]
        let url = URL(string: "\(baseUrl)/users/\(userId)")!
        requestWithoutResponse(url: createRequest(url: url, method: .PATCH, body: body as [String : Any])) {
            completion($0)
        }
    }
    
    // MARK: Spotify Management
    
    func authoriseWithSpotify(code: String, completion: @escaping (Bool) -> Void) {
        guard let userId = UserManager.shared.getId() else {
            completion(false)
            return
        }
        let url = URL(string: "\(baseUrl)/users/\(userId)/authoriseSpotify")!
        let body = ["code": code]
        requestWithoutResponse(url: createRequest(url: url, method: .POST, body: body)) {
            completion($0)
        }
    }
    
    func logoutFromSpotify(completion: @escaping (Bool) -> Void) {
        guard let userId = UserManager.shared.getId() else {
            completion(false)
            return
        }
        
        let url = URL(string: "\(baseUrl)/users/\(userId)/logoutSpotify")!
        requestWithoutResponse(url: createRequest(url: url, method: .POST)) { completion($0) }
    }
    
    func searchSpotify(for query: String, completion: @escaping ([Song]?) -> Void) {
        let url = URL(string: "\(baseUrl)/search/?query=\(query)")!
        request(url: createRequest(url: url, method: .GET)) {
            completion($0)
        }
    }
    
    // MARK: Images
    
    func uploadImage(data: Data, completion: @escaping (String?) -> Void) {
        guard let id = UserManager.shared.getId() else { return }
        let url = URL(string: "https://be759bbvrl.execute-api.eu-west-1.amazonaws.com/test/s3SignedUrl?user_id=\(id)")!
        
        request(url: createRequest(url: url, method: .GET)) { (s3Response: StorageResponse?) in
            guard let signedUrl = s3Response?.signedRequest,
                  let storageUrl = s3Response?.url else {
                completion(nil)
                return
            }
            var urlRequest = self.createRequest(url: signedUrl, method: .PUT)
            urlRequest.setValue("jpeg", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = data
            self.requestWithoutResponse(url: urlRequest) { success in
                if success {
                    completion(storageUrl.absoluteString)
                }
            }
        }
    }
    
    enum HTTPMethod: String {
        case GET
        case PUT
        case POST
        case PATCH
        case DELETE
    }
}
