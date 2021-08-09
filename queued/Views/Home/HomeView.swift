//
//  HomeView.swift
//  queued
//
//  Created by Ted Bennett on 03/08/2021.
//

import SwiftUI
import BetterSafariView

struct HomeView: View {
    @EnvironmentObject var manager: SessionManager
    @ObservedObject var viewModel = HomeViewModel()
    
    @State private var showLoginPrompt = false
    @State private var showLogoutAlert = false
    
    var loginSpotifyButton: some View {
        Button {
            viewModel.logInToSpotify()
            withAnimation {
                showLoginPrompt = false
            }
        } label: {
            ZStack {
                HStack {
                    Image("spotify_icon")
                        .resizable()
                        .frame(width: 50, height: 50)
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    Text("Login To Spotify")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Spacer()
                }
            }.padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.systemGray5))
            )
        }
    }
    
    var loggedInSpotifyView: some View {
        ZStack {
            HStack {
                Spacer()
                Text("Logged In To Spotify")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Spacer()
            }
            HStack {
                Image("spotify_icon")
                    .resizable()
                    .frame(width: 50, height: 50)
                Spacer()
                Button {
                    showLogoutAlert.toggle()
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.primary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.systemGray5))
        )
    }
    
    var createSessionButton: some View {
        Button {
            if UserManager.shared.user.host {
                viewModel.createSession()
            } else {
                withAnimation {
                    showLoginPrompt = true
                }
            }
        } label: {
            ZStack {
                HStack {
                    Spacer()
                    Text("Host a Session")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Spacer()
                    
                }
                HStack {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primary)
                }
            }
            .frame(height: 50)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.systemGray5))
            )
        }
    }
    
    var creatingSessionView: some View {
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }.frame(height: 50)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.systemGray5))
        )
    }
    
    var linkInfoView: some View {
        Group {
            Image(systemName: "link")
                .font(.title)
                .padding()
            Text("Join another session by opening \n a kude app link")
                .multilineTextAlignment(.center)
        }.foregroundColor(.gray)
    }
    
    var spaceDivider: some View {
        HStack {
            VStack {
                Divider()
            }
            Text("OR").padding()
            VStack {
                Divider()
            }
        }
    }
    
    var logoutSpotifyAlert: Alert {
        Alert(
            title: Text("Logout Spotify?"),
            primaryButton: .destructive(Text("Yes"), action: viewModel.logOutSpotify),
            secondaryButton: .cancel(Text("No"), action: {})
        )
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // TODO: Add name editing here
                Spacer()
                linkInfoView
                Spacer()
                spaceDivider
                if UserManager.shared.user.host {
                    loggedInSpotifyView
                } else {
                    loginSpotifyButton
                }
                
                if !viewModel.creatingSession {
                    createSessionButton
                } else {
                    creatingSessionView
                }
                
                if showLoginPrompt {
                    Text("Login to Spotify to create a session")
                        .foregroundColor(.red)
                        .padding()
                }
                
                NavigationLink(
                    destination: SessionView()
                        .environmentObject(manager),
                    isActive: $manager.inSession,
                    label: {
                        EmptyView()
                    })
            }.navigationTitle("Kude")
            
            
        }
        .webAuthenticationSession(isPresented: $viewModel.startingWebAuthSession) {
            viewModel.webAuthSession
        }
        .alert(isPresented: $showLogoutAlert, content: {
            logoutSpotifyAlert
        })
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .preferredColorScheme(.dark)
    }
}

struct NameView: View {
    @Binding var name: String
    @State private var editing = false
    
    var body: some View {
        HStack {
            if name == "" {
                Text("Hi")
                TextField("", text: $name)
                
            } else {
                if !editing {
                    Text("Hi, \(name)")
                } else {
                    Text("Hi,")
                    TextField("", text: $name)
                }
            }
            Button {
                editing = true
            } label: {
                Image(systemName: "pencil")
            }
        }
    }
}
