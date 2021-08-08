//
//  OldHomeView.swift
//  queued
//
//  Created by Ted Bennett on 23/03/2021.
//

import SwiftUI
import AlertToast

struct OldHomeView: View {
    @EnvironmentObject var manager: SessionManager
    @EnvironmentObject var userManager: UserManager
    
    @State private var text = ""
    @State private var presentProfile = false
    @State private var isHost = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                TextField("Enter code", text: $text)
                    .onChange(of: text) {
                        text = String($0.uppercased().prefix(6))
                        manager.failedToFindSession = false
                    }.font(Font.system(size: 25, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
//                NavigationLink(
//                    destination: SessionMemberView()
//                        .navigationBarBackButtonHidden(true),
//                    isActive: $manager.isSessionMember,
//                    label: {
//                        Button {
////                            manager.findAndJoinSession(key: text)
//                        } label: {
//                            Text("Join").font(.title2)
//                                .foregroundColor(.white)
//                                .padding()
//                                .padding(.horizontal, 30)
//                                .background(text.count == 6 ? Color.blue : Color.gray)
//                                .cornerRadius(15)
//
//                        }.disabled(text.count != 6)
//                    }).disabled(text.count != 6)
                
                if manager.failedToFindSession {
                    Text("Couldn't find a session with this key")
                        .font(.callout)
                        .foregroundColor(.red)
                }
                Spacer()
                HStack {
                    VStack {
                        Divider()
                    }
                    Text("OR").padding()
                    VStack {
                        Divider()
                    }
                }
                
                NavigationLink(destination: CreateSessionView(), label: {
                    ZStack {
                        HStack {
                            Spacer()
                            Text("Host a Session").font(.title2).foregroundColor(.white)
                            Spacer()
                            
                        }
                        HStack {
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(.white)
                        }
                    }.padding()
                    .background((userManager.user.host ?? false) ? Color.blue : Color.gray)
                    .cornerRadius(15)
                    .padding()
                }).disabled(!(userManager.user.host ?? false))
                if !(userManager.user.host ?? false) {
                    Text("Sign in to Spotify in your Profile to host a session")
                        .font(.callout)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 40)
                        .multilineTextAlignment(.center)
                }
                NavigationLink(destination: SessionHostView().navigationBarBackButtonHidden(true),
                               isActive: $manager.isSessionHost,
                               label: { EmptyView() })
                
                
            }.navigationViewStyle(StackNavigationViewStyle())
            .navigationTitle("Join A Session")
            .navigationBarItems(trailing: Button {
                presentProfile.toggle()
            } label: {
                Image(systemName: "person.circle").font(.title)
            })
            .sheet(isPresented: $presentProfile, content: {
                ProfileView(present: $presentProfile)
            })
            .toast(isPresenting: $manager.sessionEnded){
                AlertToast(displayMode: .hud, type: .regular, title: "Session Ended")
            }.onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                if manager.session != nil {
                    manager.getSession(id: manager.session!.id) { _ in}
                    manager.listenToSession()
                }
            }
            .onAppear {
                isHost = UserManager.shared.user.host ?? false
                print("Appearing \(isHost)")
            }
        }
    }
}

struct oldHomeView_Previews: PreviewProvider {
    static var previews: some View {
        OldHomeView()
    }
}
