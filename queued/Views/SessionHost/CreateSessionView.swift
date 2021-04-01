//
//  CreateSessionView.swift
//  queued
//
//  Created by Ted Bennett on 28/03/2021.
//

import SwiftUI

struct CreateSessionView: View {
    @State private var name = ""
    @State private var password = ""
    @State private var sessionCreated = false
    @ObservedObject var auth = SpotifyManager.shared
    @ObservedObject var hostViewModel = SessionHostViewModel()
    
    var body: some View {
        VStack {
            Form {
                
                List {
                    HStack {
                        Spacer()
                        Image(systemName: "camera.fill").font(.largeTitle).foregroundColor(Color(UIColor.systemGray5))
                            .frame(width: 200, height: 200)
                            .background(Color(UIColor.systemGray2))
                            .cornerRadius(5)
                        Spacer()
                    }
                    .listRowBackground(Color(UIColor.systemBackground))
                    Section(header: Text("Name")) {
                        TextField("Enter Name", text: $name)
                    }
                    Section(header: Text("Password"), footer: Text("A password allows you to control who can access your session")) {
                        HStack {
                            TextField("Enter Password (Optional)", text: $password).disableAutocorrection(true)
                        }
                    }
                    Section(header: Text("Music Service")) {
                        HStack {
                            Text("Linked with Spotify")
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                    Section {
                        Button {
                            hostViewModel.createSession(name: name)
                        } label: {
                            NavigationLink(
                                destination: SessionHostView(viewModel: hostViewModel).navigationBarBackButtonHidden(true),
                                isActive: $hostViewModel.sessionCreated,
                                label: {
                                    Text("Create Session")
                                }).disabled(!auth.loggedIn || name == "")
                        }
                    }
                }
            }.navigationTitle("Create Session")
        }
    }
}

struct CreateSessionView_Previews: PreviewProvider {
    static var previews: some View {
        CreateSessionView()
            .preferredColorScheme(.dark)
    }
}
