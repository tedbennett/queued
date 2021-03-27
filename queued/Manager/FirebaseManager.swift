//
//  FirebaseManager.swift
//  queued
//
//  Created by Ted Bennett on 27/03/2021.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirebaseManager {
    static var shared = FirebaseManager()
    
    private var db = Firestore.firestore()
    
    private init() { }
    
    func createSession(completion: @escaping (Bool) -> Void) {
        let sessions = db.collection("sessions");
        
        sessions.addDocument(data: [
            "name": "My Session",
            "host": "James",
            "host_id": "",
            "members": [],
            "queue": [],
            "created_at": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
            completion(error == nil)
        }
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
}
