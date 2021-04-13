//
//  SearchBarView.swift
//  StudyWebBrowser
//
//  Created by Andreas on 1/9/21.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @Binding var openWeb: Bool
    @Binding var webViewStore: WebViewStore
    var body: some View {
        HStack {
        TextField("Search", text: $searchText)
        
        Button(action: {
            
            searchText = searchText.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
            webViewStore.webView.load(URLRequest(url: URL(string: "https://www.google.com/search?client=safari&rls=en&q=\(searchText)&ie=UTF-8&oe=UTF-8")!))
            openWeb = true
        }) {
            Image(systemName: "magnifyingglass")
        }
        } .padding()
        .background(Color(.systemFill))
        .shadow(color: Color("Primary").opacity(0.1), radius: 15)
        .shadow(color: Color("Primary").opacity(0.2), radius: 25, x: 0, y: 20)
        .clipShape(RoundedRectangle(cornerRadius: 25.0))
    }
}

