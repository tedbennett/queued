//
//  HomeView.swift
//  queued
//
//  Created by Ted Bennett on 23/03/2021.
//

import SwiftUI

struct HomeView: View {
    @State private var text = ""
    @State private var presentProfile = false
    
    @StateObject var viewModel = SessionMemberViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                TextField("Enter code", text: $text)
                    .font(Font.system(size: 25, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button {
                    viewModel.joinSession(with: text)
                } label: {
                    NavigationLink(
                        destination: SessionMemberView(viewModel: viewModel),
                        isActive: $viewModel.gotSession,
                        label: {
                            Text("Join").font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .padding(.horizontal, 30)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }).disabled(text == "")
                }
                Spacer()
                HStack {
                    VStack {
                        Divider()
                    }
                    Text("OR").padding()
                    VStack {
                        Divider()
                    }
                }
                
                NavigationLink(
                    destination: CreateSessionView(),
                    label: {
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
                    })
                
            }.navigationTitle("Join A Session")
            .navigationBarItems(trailing: Button {
                presentProfile.toggle()
            } label: {
                Image(systemName: "person.circle").font(.title2)
            })
            .sheet(isPresented: $presentProfile, content: {
                ProfileView(present: $presentProfile)
            })
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
