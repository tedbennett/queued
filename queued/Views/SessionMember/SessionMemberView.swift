//
//  SessionMemberView.swift
//  queued
//
//  Created by Ted Bennett on 28/03/2021.
//

import SwiftUI

struct SessionMemberView: View {
    @ObservedObject var viewModel: SessionMemberViewModel
    @State private var present = false
    
    var body: some View {
        if let session = viewModel.session {
            List {
                Button {
                    present.toggle()
                } label: {
                    Text("Add Song to Queue")
                
                }
                ForEach(session.queue) { song in
                    SongCellView(song: song)
                }
            }.navigationTitle(session.name)
        
            .sheet(isPresented: $present, content: { SongSearchView(sessionId: session.id, present: $present) })
        }
    }
}

struct SessionMemberView_Previews: PreviewProvider {
    static var previews: some View {
        SessionMemberView(viewModel: SessionMemberViewModel.example)
    }
}
