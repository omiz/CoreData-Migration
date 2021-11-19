//
//  Task+Creation.swift
//  CoreData Migration
//
//  Created by Omar Allaham on 11/19/21.
//

import Foundation
extension Task {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = 0
        creationDate = Date()
    }
}
