//
//  SongSearchView.swift
//  queued
//
//  Created by Ted Bennett on 14/03/2021.
//

import SwiftUI

struct SongSearchView: View {
    @Binding var present: Bool
    
    @ObservedObject var viewModel = SpotifySearchViewModel()
    @State var isEditing = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search for tracks", text: $viewModel.searchText)
                    
                    .padding(7)
                    .background(RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray5)))
                    .cornerRadius(8)
                    .padding(.horizontal, 10)
                List {
                    ForEach(viewModel.songs) { song in
                        Button() {
                            SessionManager.shared.addSongToSession(song: song)
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                self.present.toggle()
                            }
                        } label: {
                            HStack {
                                SongCellView(song: song)
                            }
                        }
                    }
                }.listStyle(PlainListStyle())
            }
            .navigationTitle("Search")
            .navigationBarItems(trailing: Button {
                present.toggle()
            } label: {
                Text("Done")
            })
        }
    }
}

struct SongSearchView_Previews: PreviewProvider {
    static var previews: some View {
        SongSearchView(present: .constant(true), viewModel: SpotifySearchViewModel())
            .preferredColorScheme(.dark)
    }
}
