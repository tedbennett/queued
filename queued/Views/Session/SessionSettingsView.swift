//
//  SessionSettingsView.swift
//  queued
//
//  Created by Ted Bennett on 03/08/2021.
//

import SwiftUI

struct SessionSettingsView: View {
    @EnvironmentObject var manager: SessionManager
    @Binding var presented: Bool
    //@Environment(\.presentationMode) private var presentationMode
    @State private var showDeleteAlert = false
    
    @State private var delay = SessionManager.shared.session?.delay ?? 0
    @State private var sessionNameText = SessionManager.shared.session?.name ?? ""
    @State private var userNameText = UserManager.shared.user.name ?? ""
    
    private var delays = [0, 10, 20, 30, 60, 120, 180, 300, 600]
        
    init(presented: Binding<Bool>) {
        _presented = presented
    }
    
    var host: Bool {
        guard let sessionHost = manager.session?.host else {
            return false
        }
        return sessionHost == UserManager.shared.user.id
    }
    
    func delayString(_ value: Int) -> String {
        switch value {
            case 0: return "No Delay"
            case 1..<60: return "\(value) seconds"
            case 60: return "1 minute"
            case 61...: return "\(value / 60) minutes"
            default: return "Invalid delay"
        }
    }
    
    var body: some View {
        if let session = manager.session {
            NavigationView {
                Form {
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
                    
                    Section(header: Text("Settings")) {
                        if host {
                            Picker(selection: $delay, label: Text("Queue Delay")) {
                                ForEach(delays, id: \.self) {
                                    Text(delayString($0))
                                }
                            }
                        } else {
                            Text(delayString(session.delay))
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
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button {
                    if userNameText != UserManager.shared.user.name {
                        UserManager.shared.updateUser(name: userNameText) {_ in}
                    }
                    if host && (sessionNameText != session.name) {
                        manager.updateSession(name: sessionNameText)
                    }
                    if host && (delay != session.delay) {
                        manager.updateSession(delay: delay)
                    }
                    presented.toggle()
                } label: {
                    Text("Save")
                })
                .alert(isPresented: $showDeleteAlert) {
                    Alert(title: Text("Delete Session?"),
                          primaryButton: .destructive(Text("OK")) {
                            presented.toggle()
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


