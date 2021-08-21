//
//  SessionSettingsView.swift
//  queued
//
//  Created by Ted Bennett on 03/08/2021.
//

import SwiftUI

struct SessionSettingsView: View {
    @EnvironmentObject var manager: SessionManager
    @Environment(\.presentationMode) private var presentationMode
    @State private var sessionNameText = ""
    @State private var userNameText = ""
    @State private var showDeleteAlert = false
    
    @State private var frequencyIndex = 0
    private var frequencies = ["No Limit", "1", "2", "3", "4", "5"]
        
    var host: Bool {
        guard let sessionHost = manager.session?.host else {
            return false
        }
        return sessionHost == UserManager.shared.user.id
    }
    
    var body: some View {
        if let session = manager.session {
            NavigationView {
                List {
                    Section(header: Text("Session Name")) {
                        if host {
                            TextField("Session Name", text: $sessionNameText)
                        } else {
                            Text(session.name)
                        }
                    }
                    
                    Section(header: Text("Your Display Name")) {
                        TextField("Session Name", text: $userNameText)
                    }
                    
                    if host {
                        Section(header: Text("Settings")) {
                            Picker(selection: $frequencyIndex, label: Text("Queue Frequency")) {
                                ForEach(frequencies, id: \.self) {
                                    Text($0)
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Members")) {
                        ForEach(manager.users) { user in
                            Text(user.name ?? "Member")
                        }
                    }
                    
                    if host {
                        Section {
                            Button {
                                showDeleteAlert = true
                            } label: {
                                Text("Delete Session").foregroundColor(.red)
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .onAppear {
                    sessionNameText = session.name
                    userNameText = UserManager.shared.user.name ?? ""
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button {
                    if userNameText != UserManager.shared.user.name {
                        UserManager.shared.updateUser(name: userNameText) {_ in}
                    }
                    if host && (sessionNameText != session.name) {
                        manager.updateSession(name: sessionNameText)
                    }
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Save")
                })
                .alert(isPresented: $showDeleteAlert) {
                    Alert(title: Text("Delete Session?"),
                          primaryButton: .destructive(Text("OK")) {
                            presentationMode.wrappedValue.dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                
                                manager.deleteSession()
                            }
                          },
                          secondaryButton: .cancel())
                }
            }
        }
    }
}

//struct SessionSettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SessionSettingsView(host: false)
//    }
//}


