//
//  HomeView.swift
//  queued
//
//  Created by Ted Bennett on 23/03/2021.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                ProgressView()
            
                HStack {
                    VStack {
                    Divider()
                    }
                    Text("OR").padding()
                    VStack {
                        Divider()
                    }
                }
                
                Button {
                    
                } label: {
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
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
