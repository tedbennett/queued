//
//  SongSearchView.swift
//  queued
//
//  Created by Ted Bennett on 14/03/2021.
//

import SwiftUI
import AlertToast

struct SongSearchView<ViewModel: ServiceViewModel>: View {
    @ObservedObject var viewModel: ViewModel
    @State var isEditing = false
    var body: some View {
        VStack {
            HStack {
                TextField("Search for tracks", text: $viewModel.searchText)
                    .padding(7)
                    //.padding(.horizontal, 25)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, 10)
                if viewModel.searchText != "" {
                    Button() {
                        viewModel.getSongsFromSearch()
                        hideKeyboard()
                    } label: {
                        Text("Search")
                    }.padding(.trailing, 10)
                    .transition(.move(edge: .trailing))
                    .animation(.default)
                }
            }.padding()
            List {
                ForEach(viewModel.songs) { song in
                    Button() {
                        viewModel.addSongToQueue(song)
                    } label: {
                        SongListCell(song: song)
                    }
                }
            }.listStyle(PlainListStyle())
        }
        .toast(isPresenting: $viewModel.success, duration: 1, tapToDismiss: false, alert: {
            AlertToast(type: .complete(.white), title: "Added To Queue", subTitle: nil)
        }, completion: {_ in })
        .toast(isPresenting:  $viewModel.failure, duration: 1, tapToDismiss: false, alert: {
            AlertToast(type: .systemImage("warning", .white), title: "Failed To Add To Queue", subTitle: nil)
        }, completion: {_ in})
        .navigationTitle("Search")
    }
}

struct SongSearchView_Previews: PreviewProvider {
    static var previews: some View {
        SongSearchView(viewModel: SpotifySearchViewModel())
    }
}
