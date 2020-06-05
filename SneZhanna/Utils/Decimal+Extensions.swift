//
//  Decimal+Extensions.swift
//  SneZhanna
//
//  Created by Aleksei Konshin on 05.06.2020.
//  Copyright © 2020 Aleksei Konshin. All rights reserved.
//

import Foundation

extension Decimal {
    
    var numberValue: NSNumber {
        return self as NSDecimalNumber
    }
    
    var intValue: Int {
        return numberValue.intValue
    }
    
}
