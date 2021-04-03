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
    
    @State private var name = ""
    @State private var showAlert = false
    @State private var expandUsers = false
    
    var body: some View {
        NavigationView {
            Form {
                List {
                    Section(header: Text("Session Name")) {
                        TextField("Session Name", text: $name)
                    }
                    Section(header: Text("Members")) {
                        if !expandUsers {
                            ForEach(manager.users.prefix(5)) { user in
                                Text(user.name ?? "Session Member")
                            }
                            if manager.users.count > 5 {
                                Button {
                                    expandUsers.toggle()
                                } label: {
                                    Text("Show \(manager.users.count - 1) more")
                                }
                            }
                        } else {
                            ForEach(manager.users) { user in
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
                    manager.deleteSession()
                  },
                  secondaryButton: .cancel())
        }.onAppear {
            name = manager.session?.name ?? ""
        }
    }
}

//struct SessionHostSettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SessionHostSettingsView()
//    }
//}
