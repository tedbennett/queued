//
//  SongSearchView.swift
//  queued
//
//  Created by Ted Bennett on 14/03/2021.
//

import SwiftUI

struct SongSearchView: View {
    @ObservedObject var viewModel = SongSearchViewModel()
    var body: some View {
        VStack {
            HStack {
                TextField("Search for tracks", text: $viewModel.searchText).textFieldStyle(RoundedBorderTextFieldStyle())
                Button() {
                    viewModel.getSongsFromSearch()
                } label: {
                    Text("Search")
                }
            }
            List {
                ForEach(viewModel.songs) { song in
                    Button() {
                        viewModel.addSongToQueue(song)
                    } label: {
                        SongListCell(name: song.name, imageUrl: song.album.images.first?.url)
                    }
                }
            }
        }.padding()
        .navigationTitle("Search")
    }
}

struct SongSearchView_Previews: PreviewProvider {
    static var previews: some View {
        SongSearchView()
    }
}
