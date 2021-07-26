//
//  WelcomeView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 17/03/2021.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var display: Bool
    @State var name = ""
    
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 20) {
            Text("Welcome to").font(Font.system(size: 35, weight: .heavy, design: .rounded)).padding(.top, 20)
            Text("Kude").foregroundColor(.accentColor).font(Font.system(size: 40, weight: .heavy, design: .rounded))
            Spacer()
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 10) {
                    ZStack {
                        Image(systemName: "text.badge.plus").font(Font.system(size: 40)).foregroundColor(.accentColor)
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Collaborative Queues").fontWeight(.medium)
                        Text("Let your friends add music to your Spotify queue from their phones").font(.callout).foregroundColor(.gray)
                    }
                }
                HStack(spacing: 10) {
                    Image(systemName: "square.and.arrow.up").font(Font.system(size: 40)).foregroundColor(.accentColor)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Share your session").fontWeight(.medium)
                        Text("Share the link to invite others to your session").font(.callout).foregroundColor(.gray)
                    }
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Enter your name").fontWeight(.medium)
                    TextField("", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Text("Other users will be able to see this name").font(.callout).foregroundColor(.gray)
                }.padding(.leading, 55)
            }
            Spacer()
            
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                display.toggle()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .frame(height: 60)
                    Text("Got it").font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
            }
            .padding()
        }.padding()
//        .onDisappear {
//            UserDefaults.standard.setValue(AppData.version, forKey: "CurrentAppVersion")
//        }
    }
}

struct HomeVIew_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(display: .constant(true))
        
    }
}
