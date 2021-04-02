//
//  CreateSessionView.swift
//  queued
//
//  Created by Ted Bennett on 28/03/2021.
//

import SwiftUI

struct CreateSessionView: View {
    
    var user = UserManager.shared.user
    @State private var name = ""
    @State private var sessionCreated = false
    @ObservedObject var hostViewModel = SessionHostViewModel()
    
    var body: some View {
        VStack {
            Form {
                List {
                    Section(header: Text("Name")) {
                        TextField("Enter Name", text: $name)
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
                                }).disabled(user?.host == false || name == "")
                        }
                    }
                }
            }.navigationTitle("Create Session")
        }
    }
}

//struct CreateSessionView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateSessionView()
//            .preferredColorScheme(.dark)
//    }
//}
