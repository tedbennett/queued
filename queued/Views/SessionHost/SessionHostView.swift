//
//  SessionHostView.swift
//  queued
//
//  Created by Ted Bennett on 28/03/2021.
//

import SwiftUI
import AlertToast

struct SessionHostView: View {
    @EnvironmentObject var manager: SessionManager
    @Environment(\.presentationMode) var presentation
    @State private var showSettings = false
    @State var activeSheet: ActiveSheet?
    
    var body: some View {
        if let session = manager.session {
            let index = session.currentlyPlaying ?? 0
            List {
                Button {
                    activeSheet = .search
                } label: {
                    HStack {
                        Image(systemName: "plus").font(.largeTitle)
                        Text("Add Song to Queue").font(.title2).padding()
                    }
                }
                
                ForEach(session.queue.suffix(session.queue.count - index)) { song in
                    SongCellView(song: song)
                }
            }
            
            .navigationTitle(session.name)
            .navigationBarItems(trailing: HStack {
                Button {
                    shareSession()
                } label: {
                    Image(systemName: "square.and.arrow.up").font(.title)
                }
                Button {
                    activeSheet = .settings
                } label: {
                    Image(systemName: "gear").font(.title)
                }
            })
            .sheet(item: $activeSheet) { item in
                switch item {
                    case .settings:
                        SessionHostSettingsView()
                    case .search:
                        SongSearchView()
                }
            }
            .toast(isPresenting: $manager.addedSongToSession, duration: 1.0) {
                AlertToast(type: .complete(.white), title: "Added to Queue!")
            }
            .alert(isPresented: $manager.failedToAddSong) {
                Alert(title: Text("Failed to add to queue"), message: Text("No active Spotify session found on the host's account"), dismissButton: .destructive(Text("OK")))
            }
        }
    }
    
    func shareSession() {
        guard let key = SessionManager.shared.session?.key,
              let url = URL(string: "https://www.kude.app/session/\(key)") else { return }
        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
    }
    
    enum ActiveSheet: Identifiable {
        case settings, search
        
        var id: Int {
            hashValue
        }
    }
}

struct SessionHostView_Previews: PreviewProvider {
    static var previews: some View {
        SessionHostView().environmentObject(SessionManager.exampleHost)
    }
}
