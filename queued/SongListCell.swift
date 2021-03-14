//
//  SongListCell.swift
//  queued
//
//  Created by Ted Bennett on 14/03/2021.
//

import SwiftUI

struct SongListCell: View {
    var name: String?
    var imageUrl: String?
    
    var body: some View {
        HStack {
            ImageView(urlString: imageUrl).frame(width:80, height: 80).cornerRadius(8)
            Text(name ?? "Unknown Playlist")
        }
    }
}

struct SongListCell_Previews: PreviewProvider {
    static var previews: some View {
        SongListCell()
    }
}
