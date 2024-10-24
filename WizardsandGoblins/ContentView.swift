//
//  ContentView.swift
//  WizardsandGoblins
//
//  Created by Kevin Sandke on 10/23/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "happy")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Wizards and Goblins")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
