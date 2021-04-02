//
//  SongSearchView.swift
//  queued
//
//  Created by Ted Bennett on 14/03/2021.
//

import SwiftUI
import AlertToast

struct SongSearchView: View {
    @Environment(\.presentationMode) var presentation
    
    @ObservedObject var viewModel: SpotifySearchViewModel
    @State var isEditing = false
    
    init(sessionId: String) {
        viewModel = SpotifySearchViewModel(sessionId: sessionId)
    }
    
    var body: some View {
        NavigationView {
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
                            HStack {
                                SongCellView(song: song)
                            }
                        }
                    }
                }.listStyle(PlainListStyle())
            }
            .toast(isPresenting: $viewModel.success, duration: 0.5, tapToDismiss: false, alert: {
                AlertToast(type: .complete(.white), title: "Added To Queue", subTitle: nil)
            }, completion: {_ in
                presentation.wrappedValue.dismiss()
            })
            .toast(isPresenting:  $viewModel.failure, duration: 0.5, tapToDismiss: false, alert: {
                AlertToast(type: .systemImage("exclamationmark.triangle", .white), title: "Failed To Add To Queue", subTitle: nil)
            }, completion: {_ in})
            .navigationTitle("Search")
            .navigationBarItems(trailing: Button {
                presentation.wrappedValue.dismiss()
            } label: {
                Text("Done")
            })
        }
    }
}

//struct SongSearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        SongSearchView(viewModel: SpotifySearchViewModel())
//    }
//}
