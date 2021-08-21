//
//  SessionView.swift
//  queued
//
//  Created by Ted Bennett on 03/08/2021.
//

import SwiftUI
import AlertToast

struct SessionView: View {
    @EnvironmentObject var manager: SessionManager
    
    @State private var presentSearch = false
    @State private var presentSettings = false
    
    var isHost: Bool {
        guard let sessionHost = manager.session?.host else {
            return false
        }
        return sessionHost == UserManager.shared.user.id
    }
    
    func shareSession() {
        guard let session = SessionManager.shared.session else { return }
        
        let av = UIActivityViewController(activityItems: [session.url], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
    }
    
    var body: some View {
        if let session = manager.session {
            let index = session.currentlyPlaying ?? 0
            List {
                Section {
                    Button {
                        presentSearch.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                                .font(.largeTitle)
                                .frame(width:80, height: 80)
                            Text("Add Song to Queue")
                                .font(.title2)
                                .fontWeight(.heavy)
                                .padding()
                        }
                    }.buttonStyle(PlainButtonStyle())
                }
                Section {
                    ForEach(session.queue.suffix(session.queue.count - index)) { song in
                        SongCellView(song: song)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarBackButtonHidden(true)
            .navigationTitle(session.name)
            .navigationBarItems(
                leading:
                    Group {
                        if !isHost {
                            Button {
                                manager.leaveSession()
                            } label: {
                                Text("Leave").foregroundColor(.red)
                            }
                        }
                    },
                
                trailing: HStack {
                    Button {
                        shareSession()
                    } label: {
                        Image(systemName: "square.and.arrow.up").font(.title2)
                    }
                    Button {
                        presentSettings.toggle()
                    } label: {
                        Image(systemName: "gear").font(.title2)
                    }
                })
            .sheet(isPresented: $presentSearch, content: {
                SongSearchView()
            })
            .sheet(isPresented: $presentSettings, content: {
                if isHost {
                    SessionSettingsView()
                } else {
                    SessionSettingsView()
                }
            })
            
            .toast(isPresenting: $manager.addedSongToSession, duration: 1.0) {
                AlertToast(type: .complete(.white), title: "Added to Queue!")
            }
            .alert(isPresented: $manager.failedToAddSong) {
                Alert(title: Text("Failed to add to queue"), message: Text("No active Spotify session found on the host's account"), dismissButton: .destructive(Text("OK")))
            }
        }
    }
}

struct SessionVIew_Previews: PreviewProvider {
    static var previews: some View {
        SessionView()
    }
}
