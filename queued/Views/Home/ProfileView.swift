//
//  ProfileView.swift
//  queued
//
//  Created by Ted Bennett on 28/03/2021.
//

import SwiftUI
import BetterSafariView

struct ProfileView: View {
    @Binding var present: Bool
    @State private var name = ""
    @State private var imageUrl = ""
    @State private var inputImage: UIImage?
    @State private var showingImagePicker = false
    @State private var startingWebAuthenticationSession = false
    
    @ObservedObject private var userModel = UserManager.shared
    
    var body: some View {
        NavigationView {
            if let user = userModel.user {
                Form {
                        HStack {
                            Spacer()
                            Button {
                                showingImagePicker = true
                            } label: {
                                if inputImage == nil {
                                    ImageView(urlString: imageUrl)
                                        .scaledToFill()
                                        .font(.largeTitle).foregroundColor(Color(UIColor.systemGray5))
                                        .frame(width: 150, height: 150)
                                        .background(Color(UIColor.systemGray2))
                                        .cornerRadius(5)
                                } else {
                                    Image(uiImage: inputImage!)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 150, height: 150)
                                        .background(Color(UIColor.systemGray2))
                                        .cornerRadius(5)
                                }
                            }
                            Spacer()
                        }.listRowBackground(Color(UIColor.systemBackground))
                        Section(header: Text("Name"), footer: Text("Your name will be visible to other members of your session")) {
                            TextField("Enter Name", text: $name)
                        }
                        Section(header: Text("Music Service")) {
                            if user.host == true {
                                
                                HStack {
                                    Image("spotify_icon").resizable().frame(width: 50, height: 50)
                                    Text("Logged in to Spotify").padding()
                                    
                                    Spacer()
                                    Image(systemName: "checkmark").foregroundColor(.gray)
                                }
                                Button(action: {
                                    userModel.logoutFromSpotify()
                                }, label: {
                                    Text("Logout").foregroundColor(.red)
                                })
                            } else {
                                Button {
                                    startingWebAuthenticationSession = true
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
            
        }
        }.onAppear {
            UserManager.shared.getUser() { user in
                guard let user = user else {
                    return
                }
                name = user.name ?? ""
                imageUrl = user.imageUrl ?? ""
            }
        }.sheet(isPresented: $showingImagePicker, onDismiss: uploadImage) {
            ImagePicker(image: $inputImage)
        }
        .webAuthenticationSession(isPresented: $startingWebAuthenticationSession) {
            WebAuthenticationSession(
                url: URL(string: "https://accounts.spotify.com/authorize?client_id=1e6ef0ef377c443e8ebf714b5b77cad7&response_type=code&redirect_uri=queued://oauth-callback/&scope=user-read-private%20user-modify-playback-state%20user-read-recently-played%20user-read-playback-state&show_dialog=true")!,
                callbackURLScheme: "queued"
            ) { callbackURL, error in
                guard let callbackURL = callbackURL, error == nil, let url = URLComponents(url: callbackURL, resolvingAgainstBaseURL: true), let code = url.queryItems?.first(where: { $0.name == "code" })?.value  else {
                    print(error.debugDescription)
                    return
                }
                
                    UserManager.shared.authoriseWithSpotify(code: code)
            }
        }
    }
    
    func uploadImage() {
        guard let data = inputImage?.jpegData(compressionQuality: 0.3) else { return }
        FirebaseManager.shared.uploadImage(data: data, completion: { url in
            if let url = url {
                imageUrl = url
            }
        })
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(present: .constant(true))
            .preferredColorScheme(.dark)
    }
}
