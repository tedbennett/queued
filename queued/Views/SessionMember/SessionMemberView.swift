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
                ForEach(session.queue) { song in
                    Text(song.name)
                }
            }.navigationTitle(session.name)
        }
    }
}

//struct SessionMemberView_Previews: PreviewProvider {
//    static var previews: some View {
//        SessionMemberView()
//    }
//}
