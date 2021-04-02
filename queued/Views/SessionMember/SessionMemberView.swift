//
//  SessionMemberView.swift
//  queued
//
//  Created by Ted Bennett on 28/03/2021.
//

import SwiftUI

struct SessionMemberView: View {
    @EnvironmentObject var manager: SessionManager
    @Environment(\.presentationMode) var presentation
    @State var activeSheet: ActiveSheet?
    
    var body: some View {
        if let session = manager.session {
            List {
                Button {
                    activeSheet = .search
                } label: {
                    HStack {
                        Image(systemName: "plus").font(.largeTitle)
                        Text("Add Song to Queue").font(.title2).padding()
                    }
                }
                ForEach(session.queue) { song in
                    SongCellView(song: song)
                }
            }.navigationTitle(session.name)
            .navigationBarItems(leading: Button {
                manager.leaveSession()
            } label: {
                Text("Leave").foregroundColor(.red)
            }, trailing: Button {
                activeSheet = .members
            } label: {
                Image(systemName: "person.2.circle").font(.title)
            })
            .sheet(item: $activeSheet) { item in
                switch item {
                    case .members:
                        SessionMemberDetailsView()
                    case .search:
                        SongSearchView(sessionId: session.id)
                }
            }
        }
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
