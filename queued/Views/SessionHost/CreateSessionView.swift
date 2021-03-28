//
//  CreateSessionView.swift
//  queued
//
//  Created by Ted Bennett on 28/03/2021.
//

import SwiftUI

struct CreateSessionView: View {
    @State private var name = ""
    @State private var sessionCreated = false
    @ObservedObject var auth = SpotifyHostManager.shared
    @ObservedObject var hostViewModel = SessionHostViewModel()
    
    var body: some View {
        VStack {
            
            Image(systemName: "camera.fill").font(.largeTitle).foregroundColor(Color(UIColor.systemGray5))
                .frame(width: 250, height: 250)
                .background(Color(UIColor.systemGray2))
                .cornerRadius(5)
                .padding(40)
            
            TextField("Session Name", text: $name).font(Font.system(size: 25, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
            Text("Please enter a valid name").padding(3).foregroundColor(.red).font(.callout).hidden()
            
            Button {
                auth.login()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(UIColor.secondarySystemFill))
                        .frame(height: 80)
                    HStack {
                        Image("spotify_icon")
                            .resizable()
                            .frame(width: 40, height: 40)
                        
                        if auth.token == nil {
                            Text("Log In to Spotify").font(Font.system(size: 20, weight: .semibold, design: .rounded))
                                .padding(.horizontal, 10)
                            Spacer()
                        } else {
                            Text("Logged In to Spotify").font(Font.system(size: 20, weight: .semibold, design: .rounded))
                                .padding(.horizontal, 10)
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }.padding(20)
                }
            }.accentColor(.white)
            .disabled(auth.token != nil)
            .padding(40)
            
            Button {
                hostViewModel.createSession(name: name)
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(auth.token == nil ? Color(UIColor.secondarySystemFill) : Color.blue)
                    HStack {
                        Spacer()
                        Text("Create Session").font(Font.system(size: 20, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 10)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }.padding()
                }
                .frame(width: 250, height: 80)
            }
            .disabled(auth.token == nil)
            Spacer()
            NavigationLink("", destination: SessionHostView(viewModel: hostViewModel), isActive: $hostViewModel.sessionCreated)
        }.navigationTitle("Create Session")
    }
}

struct CreateSessionView_Previews: PreviewProvider {
    static var previews: some View {
        CreateSessionView()
            .preferredColorScheme(.dark)
    }
}
