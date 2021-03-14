//
//  HomeView.swift
//  queued
//
//  Created by Ted Bennett on 14/03/2021.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = ViewModel.shared
    
    var body: some View {
        if viewModel.authenticated {
            SongSearchView()
        } else {
            Button(action: {
                viewModel.authorize()
            }, label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).foregroundColor(.gray).frame(width: 250, height: 100)
                    Text("Log In to Spotify").foregroundColor(.white).font(.title2).padding()
                }
            })
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
