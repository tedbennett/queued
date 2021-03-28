//
//  FirebaseManager.swift
//  queued
//
//  Created by Ted Bennett on 27/03/2021.
//

import Foundation
import FirebaseFunctions
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirebaseManager {
    static var shared = FirebaseManager()
    
    private var db = Firestore.firestore()
    private var functions = Functions.functions()
    
    private init() {
        
    }
    
    // MARK: Session
    func createSession(name: String, token: String, completion: @escaping (Session?) -> Void) {
        guard let userId = UserManager.shared.getId() else {
            completion(nil)
            return
        }
        
        let date = Date()
        let data: [String : Any] = ["name": name, "host": userId, "members": [], "queue": [], "created_at": date]
        
        let sessions = self.db.collection("sessions");
        
        let ref = sessions.addDocument(data: data) { _ in }
        let key = ref.documentID.prefix(6).uppercased()
        ref.setData(["id": ref.documentID, "token": token, "key": key], merge: true)
        
        let session = Session(id: ref.documentID, name: name, key: key, host: userId, members: [], queue: [], createdAt: date)
        
        completion(session)
    }
    
    func getSession(id: String, completion:  @escaping (Session?) -> Void) {
        let sessions = db.collection("sessions");
        
        sessions.document(id).getDocument { document, error in
            guard let document = document else {
                print("Error fetching document: \(error!)")
                completion(nil)
                return
            }
            
            let result = Result {
                try document.data(as: Session.self)
            }
            switch result {
                case .success(let session):
                    if let session = session {
                        completion(session)
                    } else {
                        print("Document does not exist")
                        completion(nil)
                    }
                case .failure(let error):
                    print("Error decoding session: \(error)")
                    completion(nil)
            }
        }
    }
    
    func joinSession(key: String, completion:  @escaping (Session?) -> Void) {
        guard let id = UserManager.shared.getId() else {
            completion(nil)
            return
        }
        let sessions = self.db.collection("sessions");
        
        sessions.whereField("key", isEqualTo: key).getDocuments() { data, error in
            guard let document = data?.documents.first else {
                print("Couldn't find key")
                completion(nil)
                return
            }
            
            let result = Result {
                try document.data(as: Session.self)
            }
            switch result {
                case .success(let session):
                    if let session = session {
                        sessions.document(session.id).updateData([
                            "members": FieldValue.arrayUnion([id])
                        ])
                        completion(session)
                    } else {
                        print("Document does not exist")
                        completion(nil)
                    }
                case .failure(let error):
                    print("Error decoding session: \(error)")
                    completion(nil)
            }
        }
        
    }
    
    func addSongToQueue(uri: String, sessionId: String, completion: @escaping (Bool) -> Void) {
        
        let query = [
            "songUri": uri,
            "sessionId": sessionId
        ]
        functions.httpsCallable("addSongToQueue").call(query) { _, _ in
            
        }
    }
    
    func listenToSession(id: String, snapshotCompletion: @escaping (Session?) -> Void) {
        let sessions = db.collection("sessions");
        
        sessions.document(id).addSnapshotListener { snapshot, error in
            guard let document = snapshot else {
                print("Error fetching document: \(error!)")
                snapshotCompletion(nil)
                return
            }
            
            let result = Result {
                try document.data(as: Session.self)
            }
            switch result {
                case .success(let session):
                    if let session = session {
                        snapshotCompletion(session)
                    } else {
                        print("Document does not exist")
                        snapshotCompletion(nil)
                    }
                case .failure(let error):
                    print("Error decoding session: \(error)")
                    snapshotCompletion(nil)
            }
        }
    }
    
    func deleteSession(id: String, completion: @escaping (Bool) -> Void) {
        let sessions = db.collection("sessions");
        
        sessions.document(id).delete() { error in
            if let error = error {
                print(error.localizedDescription)
            }
            completion(error == nil)
        }
    }
    
    // MARK: User
    func createUser() -> String {
        let newUser = db.collection("users").document();
        let id = newUser.documentID
        newUser.setData([
            "id": id
        ])
        return id
    }
    
    func getUser(id: String, completion: @escaping (User?) -> Void) {
        let users = db.collection("users");
        
        users.document(id).getDocument { document, error in
            guard let document = document else {
                print("Error fetching document: \(error!)")
                completion(nil)
                return
            }
            let result = Result {
                try document.data(as: User.self)
            }
            switch result {
                case .success(let user):
                    if let user = user {
                        completion(user)
                    } else {
                        print("Document does not exist")
                        completion(nil)
                    }
                case .failure(let error):
                    print("Error decoding session: \(error)")
                    completion(nil)
            }
        }
    }
    
    func updateUser(_ user: User) -> Bool {
        let users = db.collection("users");
        do {
            try users.document(user.id).setData(from: user)
            return true
        } catch let error {
            print("Error writing city to Firestore: \(error)")
            return false
        }
    }
}
