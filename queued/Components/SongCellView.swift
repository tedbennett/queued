//
//  SongCellView.swift
//  queued
//
//  Created by Ted Bennett on 01/04/2021.
//

import SwiftUI

struct SongCellView: View {
    var song: Song
    var body: some View {
        HStack {
            ImageView(urlString: song.imageUrl).frame(width:80, height: 80).cornerRadius(8)
            VStack(alignment: .leading) {
                Text(song.name).font(.title2).fontWeight(.heavy)
                Text("\(song.artist) - \(song.album)").foregroundColor(.gray).font(.callout)
            }.padding(5)
        }
    }
}

//struct SongCellView_Previews: PreviewProvider {
//    static var previews: some View {
//        SongCellView()
//    }
//}
