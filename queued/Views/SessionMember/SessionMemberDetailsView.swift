//
//  SessionMemberDetailsView.swift
//  queued
//
//  Created by Ted Bennett on 02/04/2021.
//

import SwiftUI

struct SessionMemberDetailsView: View {
    @EnvironmentObject var manager: SessionManager
    
    var body: some View {
        NavigationView {
            List {
                ForEach(manager.users) { user in
                    HStack {
                        ImageView(urlString: user.imageUrl ?? "").frame(width:80, height: 80)
                            .background(Color(UIColor.systemGray2))
                            .cornerRadius(40)
                        Text(user.name ?? "Session member").font(.title2)
                    }.padding(5)
                }
            }.navigationTitle("Session Members")
        }
    }
}

//struct SessionMemberDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SessionMemberDetailsView()
//    }
//}
