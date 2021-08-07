//
//  FirebaseManager.swift
//  queued
//
//  Created by Ted Bennett on 26/07/2021.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseFunctions

class FirebaseManager {
    static var shared = FirebaseManager()
    
    private init() { }
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    lazy private var functions = Functions.functions()
    
    // MARK: Sessions
    func createSession(name: String, completion: @escaping (Session?) -> Void) {
        let userId = UserManager.shared.user.id
        let id = UUID().uuidString
        db.collection("sessions").document(id).setData([
            "id": id,
            "name": name,
            "host": userId,
            "members": [userId],
            "queue": [],
            "createdAt": Date().timeIntervalSince1970,
            "updatedAt": Date().timeIntervalSince1970
        ]) { error in
            guard error == nil else {
                completion(nil)
                return
            }
            self.getSession(id: id) { session in
                completion(session)
            }
        }
    }
    
    func decode<T: Decodable>(json: [String:Any]) -> T? {
        guard let data = try? JSONSerialization.data(withJSONObject: json) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return try? decoder.decode(T.self, from: data)
    }
    
    func getSession(id: String, completion:  @escaping (Session?) -> Void) {
        db.collection("sessions").document(id).getDocument { doc, error in
            guard let data = doc?.data() else {
                completion(nil)
                return
            }
            completion(self.decode(json: data))
        }
    }
    
    func updateSessionName(id: String, name: String, completion: @escaping (Bool) -> Void) {
        db.collection("sessions").document(id).updateData([
            "name": name,
            "updatedAt": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
            completion(error == nil)
        }
    }
    
    
    func joinSession(id: String, completion:  @escaping (Session?) -> Void) {
        let userId = UserManager.shared.user.id
        db.collection("sessions").document(id).updateData([
            "users": FieldValue.arrayUnion([userId]),
            "updatedAt": FieldValue.serverTimestamp()
        ]) { error in
            guard error == nil else {
                print(error.debugDescription)
                completion(nil)
                return
            }
            self.db.collection("users").document(userId).updateData([
                "session": id
            ])
            self.getSession(id: id, completion: completion)
        }
    }
    
    func leaveSession(id: String, completion: @escaping (Bool) -> Void) {
        let userId = UserManager.shared.user.id
        db.collection("sessions").document(id).updateData([
            "users": FieldValue.arrayUnion([id]),
            "updatedAt": FieldValue.serverTimestamp()
        ])
        db.collection("users").document(userId).updateData([
            "session": NSNull()
        ])
    }
    
    func addSongToQueue(_ song: Song, sessionId: String, completion: @escaping (Bool) -> Void) {
        functions.httpsCallable("addSongToQueue").call(["song": song, "sessionId": sessionId]) { result, error in
            guard error == nil else {
                print(error.debugDescription)
                completion(false)
                return
            }
            if let data = result?.data as? [String: Any], let result = data["result"] as? Bool {
                completion(result)
            } else {
                completion(false)
            }
        }
    }
    
    func checkCurrentlyPlaying(id: String) {
        
    }
    
    func listenToSession(id: String, completion: @escaping (Session?) -> Void) {
        listener = db.collection("sessions").document(id).addSnapshotListener { snapshot, error in
            guard let document = snapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                completion(nil)
                return
            }
            completion(self.decode(json: data))
        }
    }
    
    func stopListeningToSession() {
        listener?.remove()
    }
    
    func deleteSession(id: String, completion: @escaping (Bool) -> Void) {
        db.collection("sessions").document(id).delete()
    }
    
    // MARK: User
    func createUser(id: String, completion: @escaping (Bool) -> Void) {
        db.collection("users").document(id).setData([
            "id":id
        ]) { error in
            completion(error == nil )
        }
    }
    
    func getUser(id: String, completion: @escaping (User?) -> Void) {
        db.collection("users").document(id).getDocument { doc, error in
            guard let data = doc?.data() else {
                completion(nil)
                return
            }
            completion(self.decode(json: data))
        }
    }
    
    func updateUser(name: String, completion: @escaping (Bool) -> Void) {
        let userId = UserManager.shared.user.id
        db.collection("users").document(userId).updateData([
            "name": name
        ]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
            completion(error == nil)
        }
    }
    
    // MARK: Spotify Management
    
    func authoriseWithSpotify(code: String, completion: @escaping (Bool) -> Void) {
        let userId = UserManager.shared.user.id
        functions.httpsCallable("authoriseSpotify").call(["code": code, "userId": userId]) { result, error in
            guard error == nil else {
                print(error.debugDescription)
                completion(false)
                return
            }
            if let data = result?.data, let result = data as? Bool {
                completion(result)
            } else {
                completion(false)
            }
        }
    }
    
    func logoutFromSpotify(completion: @escaping (Bool) -> Void) {
        let userId = UserManager.shared.user.id
        db.collection("users").document(userId).updateData([
            "accessToken": NSNull(),
            "refreshToken": NSNull(),
            "expiresAt": NSNull()
        ])
        completion(true)
    }
    
    func searchSpotify(for query: String, completion: @escaping ([Song]?) -> Void) {
        functions.httpsCallable("searchSpotify").call(["query": query]) { result, error in
            guard error == nil else {
                print(error.debugDescription)
                completion(nil)
                return
            }
            if let data = result?.data as? [String: Any], let result = data["result"] as? [String: Any] {
                completion(self.decode(json: result))
            }
        }
    }
    
    // MARK: Images
    
    func uploadImage(data: Data, completion: @escaping (String?) -> Void) {
    }
}
