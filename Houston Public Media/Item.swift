//
//  Item.swift
//  Houston Public Media
//
//  Created by Jared Counts on 10/8/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
