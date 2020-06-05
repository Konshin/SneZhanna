//
//  SteppableInput.swift
//  SneZhanna
//
//  Created by Aleksei Konshin on 05.06.2020.
//  Copyright © 2020 Aleksei Konshin. All rights reserved.
//

import SwiftUI

//struct SteppableInput: View {
//    
//    @State var value: Int
//    let range: ClosedRange<Int>
//    let placeholder: String
//    let transform: (Int) -> String
//    
//    var body: some View {
//        let textBinding = Binding<String>(get: { self.transform(self.value) },
//                                          set: { self.value = Int($0) ?? 0 })
//        
//        return HStack {
//            TextField(placeholder, text: textBinding)
//            Stepper(value: $value, in: range) { "" }
//        }
//    }
//    
//}

//struct SteppableInput_Previews: PreviewProvider {
//    static var previews: some View {
//        SteppableInput(value: 10, range: 1...100, placeholder: "Test") { "\($0)$" }
//    }
//}
