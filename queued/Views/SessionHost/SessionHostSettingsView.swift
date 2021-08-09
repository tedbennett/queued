//
//  SessionHostSettingsView.swift
//  queued
//
//  Created by Ted Bennett on 02/04/2021.
//

import SwiftUI

struct SessionHostSettingsView: View {
    @EnvironmentObject var manager: SessionManager
    @Environment(\.presentationMode) var presentation
    
    @State private var name = SessionManager.shared.session?.name ?? ""
    @State private var showAlert = false
    @State private var expandUsers = false
    
//    var key: String  {
//        SessionManager.shared.session?.key ?? ""
//    }
    
    var users: [User]  {
        SessionManager.shared.users
    }
    
    var body: some View {
        NavigationView {
            Form {
                List {
                    Section(header: Text("Session Name")) {
                        TextField("Session Name", text: $name)
                    }
//                    Section(header: Text("Session Key"), footer: Text("Send this to others to invite them to your session")) {
//                        HStack {
//                            Text(key)
//                            Spacer()
//                            Button {
//                                UIPasteboard.general.string = key
//                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                            } label: {
//                                Image(systemName: "square.on.square").font(.title3)
//                            }
//                            Button {
//                                
//                            } label: {
//                                Image(systemName: "square.and.arrow.up").font(.title3)
//                            }
//                        }
//                    }
                    Section(header: Text("Members")) {
                        if !expandUsers {
                            ForEach(users.prefix(5)) { user in
                                Text(user.name ?? "Session Member")
                            }
                            if users.count > 5 {
                                Button {
                                    expandUsers.toggle()
                                } label: {
                                    Text("Show \(users.count - 5) more")
                                }
                            }
                        } else {
                            ForEach(users) { user in
                                Text(user.name ?? "Session Member")
                            }
                        }
                    }
                    Button {
                        showAlert = true
                    } label: {
                        Text("Delete Session").foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button {
                if name != manager.session?.name {
                    manager.updateSession(name: name)
                }
                presentation.wrappedValue.dismiss()
            } label: {
                Text("Done")
            })
        }.alert(isPresented: $showAlert) {
            Alert(title: Text("Delete Session?"),
                  primaryButton: .destructive(Text("OK")) {
                    presentation.wrappedValue.dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        manager.deleteSession()
                    }
                  },
                  secondaryButton: .cancel())
        }
    }
}

struct SessionHostSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SessionHostSettingsView()
            .environmentObject(SessionManager.exampleHost)
    }
}
