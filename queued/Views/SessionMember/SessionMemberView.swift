//
//  SessionMemberView.swift
//  queued
//
//  Created by Ted Bennett on 28/03/2021.
//

import SwiftUI
import AlertToast

struct SessionMemberView: View {
    @EnvironmentObject var manager: SessionManager
    @Environment(\.presentationMode) var presentation
    @State var activeSheet: ActiveSheet?
    
    var body: some View {
        if let session = manager.session {
            let currentlyPlaying = session.currentlyPlaying ?? 0
            List {
                Button {
                    activeSheet = .search
                } label: {
                    HStack {
                        Image(systemName: "plus").font(.largeTitle)
                        Text("Add Song to Queue").font(.title2).padding()
                    }
                }
                ForEach(session.queue.suffix(session.queue.count - currentlyPlaying)) { song in
                    ZStack {
                        SongCellView(song: song)
                    }
                }
            }.navigationTitle(session.name)
            .navigationBarItems(leading: Button {
                manager.leaveSession()
            } label: {
                Text("Leave").foregroundColor(.red)
            }, trailing: HStack {
                Button {
                    shareSession()
                } label: {
                    Image(systemName: "square.and.arrow.up").font(.title)
                }
                Button {
                    activeSheet = .members
                } label: {
                    Image(systemName: "person.2.circle").font(.title)
                }
                })
            .sheet(item: $activeSheet) { item in
                switch item {
                    case .members:
                        SessionMemberDetailsView()
                    case .search:
                        SongSearchView()
                }
            }
            .toast(isPresenting: $manager.addedSongToSession, duration: 1.0) {
                AlertToast(type: .complete(.black), title: "Added to Queue!")
            }
            .alert(isPresented: $manager.failedToAddSong) {
                Alert(title: Text("Failed to add to queue"), message: Text("No active Spotify session was found on the host's account"), dismissButton: .destructive(Text("OK")))
            }
        }
    }
    
    func shareSession() {
        guard let id = SessionManager.shared.session?.id,
              let url = URL(string: "https://www.kude.app/session/\(id)") else { return }
        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
    }
    
    enum ActiveSheet: Identifiable {
        case members, search
        
        var id: Int {
            hashValue
        }
    }
}

struct SessionMemberView_Previews: PreviewProvider {
    static var previews: some View {
        SessionMemberView()
    }
}
