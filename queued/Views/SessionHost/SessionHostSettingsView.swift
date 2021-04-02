//
//  SessionHostSettingsView.swift
//  queued
//
//  Created by Ted Bennett on 02/04/2021.
//

import SwiftUI

struct SessionHostSettingsView: View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var viewModel: SessionHostViewModel
    
    @State private var name = ""
    @State private var showAlert = false
    
    func closeSession() {
        viewModel.deleteSession()
    }
    
    var body: some View {
        NavigationView {
            Form {
                List {
                    Section(header: Text("Session Name")) {
                        TextField("Session Name", text: $name)
                    }
                    Button {
                        showAlert = true
                    } label: {
                        Text("Delete Session").foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button {
                presentation.wrappedValue.dismiss()
            } label: {
                Image(systemName: "xmark").font(.title)
            })
        }.alert(isPresented: $showAlert) {
            Alert(title: Text("Delete Session?"),
                  primaryButton: .destructive(Text("OK")) {
                    presentation.wrappedValue.dismiss()
                    viewModel.deleteSession()
                  },
                  secondaryButton: .cancel())
        }
        .onAppear {
            name = viewModel.session?.name ?? ""
        }
    }
}

//struct SessionHostSettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SessionHostSettingsView()
//    }
//}
