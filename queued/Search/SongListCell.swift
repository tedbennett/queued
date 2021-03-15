//
//  SongListCell.swift
//  queued
//
//  Created by Ted Bennett on 14/03/2021.
//

import SwiftUI

struct SongListCell: View {
    var song: Song
    
    var body: some View {
        HStack {
            ImageView(urlString: song.imageUrl).frame(width:80, height: 80).cornerRadius(8)
            Text(song.name)
        }
    }
}

struct SongListCell_Previews: PreviewProvider {
    static var previews: some View {
        SongListCell(song: Song.example)
    }
}
