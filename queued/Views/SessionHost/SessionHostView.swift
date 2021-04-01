//
//  SessionHostView.swift
//  queued
//
//  Created by Ted Bennett on 28/03/2021.
//

import SwiftUI

struct SessionHostView: View {
    @ObservedObject var viewModel: SessionHostViewModel
    
    var body: some View {
        if let session = viewModel.session {
            VStack {
                Text(session.key).font(Font.system(size: 30, weight: .semibold, design: .rounded))
                HStack {
                    Button {
                        UIPasteboard.general.string = session.key
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    } label: {
                        Image(systemName: "square.on.square").font(.title2).padding()
                    }
                    Button {
                        
                    } label: {
                        Image(systemName: "square.and.arrow.up").font(.title2).padding()
                    }
                }
                List {
                    ForEach(session.members, id: \.self) {
                        Text($0)
                    }
                }
            }
            .navigationTitle(session.name)
        }
    }
}

struct SessionHostView_Previews: PreviewProvider {
    static var previews: some View {
        SessionHostView(viewModel: SessionHostViewModel.example)
    }
}
