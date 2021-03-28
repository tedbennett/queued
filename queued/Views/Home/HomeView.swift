//
//  HomeView.swift
//  queued
//
//  Created by Ted Bennett on 23/03/2021.
//

import SwiftUI

struct HomeView: View {
    @State private var text = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter code", text: $text)
                    .font(Font.system(size: 25, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                Spacer()
                
                Button {
                    
                } label: {
                    Text("Search")
                }
            
                HStack {
                    VStack {
                    Divider()
                    }
                    Text("OR").padding()
                    VStack {
                        Divider()
                    }
                }
                
                NavigationLink(
                    destination: CreateSessionView(),
                    label: {
                        HStack {
                            Spacer()
                            Text("Host a Session").foregroundColor(.white).fontWeight(.medium)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15)
                        .padding()
                    })
                
            }.navigationTitle("Join A Session")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
