//
//  Points.swift
//  StudyWebBrowser
//
//  Created by Andreas on 1/9/21.
//

import SwiftUI

struct User: Identifiable, Codable, Hashable{
    var id: String
    var name: String
    var points: Int
    var date: Date
    
}

struct Day: Identifiable, Codable, Hashable{
    var id: String
    var points: Int
    var date: Date
    
}
