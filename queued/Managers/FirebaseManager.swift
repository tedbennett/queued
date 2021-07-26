//
//  FirebaseManager.swift
//  queued
//
//  Created by Ted Bennett on 26/07/2021.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FirebaseManager {
    static var shared = FirebaseManager()
    
    private init() {
        
    }
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    // MARK: Sessions
    func createSession(name: String, completion: @escaping (Session?) -> Void) {
        guard let userId = UserManager.shared.getId() else {
            completion(nil)
            return
        }
        let id = UUID().uuidString
        db.collection("sessions").document(id).setData([
            "id": id,
            "name": name,
            "host": userId,
            "members": [userId],
            "queue": [],
            "createdAt": Date(),
            "updatedAt": Date()
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
        return try? JSONDecoder().decode(T.self, from: data)
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
        guard let userId = UserManager.shared.getId() else {
            return
        }
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
        guard let userId = UserManager.shared.getId() else {
            return
        }
        db.collection("sessions").document(id).updateData([
            "users": FieldValue.arrayUnion([id]),
            "updatedAt": FieldValue.serverTimestamp()
        ])
        db.collection("users").document(userId).updateData([
            "session": NSNull()
        ])
    }
    
    func addSongToQueue(_ song: Song, sessionId: String, completion: @escaping (Bool) -> Void) {
        getSession(id: sessionId) { session in
            guard let session = session else {
                completion(false)
                return
            }
            
            var songs = session.queue
            songs.append(song)
            
            self.db.collection("sessions").document(sessionId).updateData([
                "queue": songs,
                "updatedAt": FieldValue.serverTimestamp()
            ])
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
    func createUser(completion: @escaping (String?) -> Void) {
        let id = UUID().uuidString
        db.collection("users").document(id).setData([
            "id":id
        ]) { error in
            guard error == nil else {
                completion(nil)
                return
            }
            completion(id)
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
        guard let id = UserManager.shared.getId() else {
            completion(false)
            return
        }
        db.collection("users").document(id).updateData([
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
    }
    
    func logoutFromSpotify(completion: @escaping (Bool) -> Void) {
        
    }
    
    func searchSpotify(for query: String, completion: @escaping ([Song]?) -> Void) {
    }
    
    // MARK: Images
    
    func uploadImage(data: Data, completion: @escaping (String?) -> Void) {
    }
}
