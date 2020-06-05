//
//  TitledContainer.swift
//  SneZhanna
//
//  Created by Aleksei Konshin on 05.06.2020.
//  Copyright © 2020 Aleksei Konshin. All rights reserved.
//

import SwiftUI

struct TitledContainer<Content: View>: View {
    
    let title: String
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).foregroundColor(.secondary)
            content()
        }
    }
}

struct TitledContainer_Previews: PreviewProvider {
    
    static var previews: some View {
        TitledContainer(title: "Test") {
            Text("Test here")
        }
    }
}
