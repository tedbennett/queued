//
//  ProfileView.swift
//  queued
//
//  Created by Ted Bennett on 28/03/2021.
//

import SwiftUI

struct ProfileView: View {
    @Binding var present: Bool
    @State private var name = ""
    @State private var imageUrl: String?
    @State private var host = false
    
    @ObservedObject private var auth = SpotifyManager.shared
    var body: some View {
        NavigationView {
            Form {
                List {
                    HStack {
                        Spacer()
                        Image(systemName: "camera.fill").font(.largeTitle).foregroundColor(Color(UIColor.systemGray5))
                            .frame(width: 150, height: 150)
                            .background(Color(UIColor.systemGray2))
                            .cornerRadius(5)
                        Spacer()
                    }.listRowBackground(Color(UIColor.systemBackground))
                    Section(header: Text("Name"), footer: Text("Your name will be visible to other members of your session")) {
                        TextField("Enter Name", text: $name)
                    }
                    Section(header: Text("Music Service")) {
                        if auth.loggedIn || host {
                            
                            HStack {
                                Image("spotify_icon").resizable().frame(width: 50, height: 50)
                                Text("Logged in to Spotify").padding()
                                
                                Spacer()
                                Image(systemName: "checkmark").foregroundColor(.gray)
                            }
                            Button(action: {
                                //auth.logout()
                            }, label: {
                                Text("Logout").foregroundColor(.red)
                            })
                        } else {
                            Button {
                                auth.login()
                            } label: {
                                HStack {
                                    Image("spotify_icon").resizable().frame(width: 50, height: 50)
                                    Text("Log In to Spotify").padding()
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundColor(.gray)
                                }
                            }.buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }.navigationTitle("Your Profile")
            .navigationBarItems(leading: Button {
                present = false
            } label: {
                Image(systemName: "xmark")
            }, trailing: Button {
                UserManager.shared.updateUser(name: name, imageUrl: imageUrl) { _ in }
                present = false
            } label: {
                Text("Save")
            })
        }.onAppear {
            UserManager.shared.getUser() { user in
                guard let user = user else {
                    return
                }
                name = user.name ?? ""
                imageUrl = user.imageUrl ?? nil
                host = user.host ?? false
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(present: .constant(true))
            .preferredColorScheme(.dark)
    }
}
