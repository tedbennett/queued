//
//  SessionHostView.swift
//  queued
//
//  Created by Ted Bennett on 28/03/2021.
//

import SwiftUI

struct SessionHostView: View {
    @ObservedObject var viewModel: SessionHostViewModel
    
    var body: some View {
        Text(viewModel.session?.name ?? "Name")
            .navigationTitle("Your Session")
    }
}

struct SessionHostView_Previews: PreviewProvider {
    static var previews: some View {
        SessionHostView(viewModel: SessionHostViewModel.example)
    }
}
