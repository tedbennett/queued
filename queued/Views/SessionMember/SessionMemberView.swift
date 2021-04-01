//
//  SessionMemberView.swift
//  queued
//
//  Created by Ted Bennett on 28/03/2021.
//

import SwiftUI

struct SessionMemberView: View {
    @ObservedObject var viewModel: SessionMemberViewModel
    var body: some View {
        if let session = viewModel.session {
            List {
                Text("Add Song to Queue")
                ForEach(session.members, id: \.self) { song in
                    Text(song)
                }
            }.navigationTitle(session.name)
        }
    }
}

struct SessionMemberView_Previews: PreviewProvider {
    static var previews: some View {
        SessionMemberView(viewModel: SessionMemberViewModel.example)
    }
}
