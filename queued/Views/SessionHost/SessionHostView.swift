//
//  SessionHostView.swift
//  queued
//
//  Created by Ted Bennett on 28/03/2021.
//

import SwiftUI

struct SessionHostView: View {
    @EnvironmentObject var manager: SessionManager
    @Environment(\.presentationMode) var presentation
    @State private var showSettings = false
    
    var body: some View {
        if let session = manager.session {
            VStack {
                HStack {
                    Text(session.key).font(Font.system(size: 30, weight: .semibold, design: .rounded))
                
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
                    ForEach(manager.users) { user in
                        HStack {
                            ImageView(urlString: user.imageUrl ?? "").frame(width:80, height: 80)
                                .background(Color(UIColor.systemGray2))
                                .cornerRadius(40)
                            Text(user.name ?? "Session member").font(.title2)
                        }.padding(5)
                    }
                }
            }
            .navigationTitle(session.name)
            .navigationBarItems(trailing: Button {
                showSettings = true
            } label: {
                Image(systemName: "gear").font(.title)
            })
            .sheet(isPresented: $showSettings) {
                SessionHostSettingsView()
            }
        }
    }
}

//struct SessionHostView_Previews: PreviewProvider {
//    static var previews: some View {
//        SessionHostView(viewModel: SessionHostViewModel.example)
//    }
//}
