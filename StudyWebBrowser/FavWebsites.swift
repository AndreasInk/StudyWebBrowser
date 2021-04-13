//
//  FavWebsites.swift
//  StudyWebBrowser
//
//  Created by Andreas on 1/9/21.
//

import SwiftUI

struct FavWebsites: Identifiable, Codable, Hashable{
    var id: String
    var title: String
    var website: String
    var isProductive: Bool
}
