//
//  BrowsingView.swift
//  StudyWebBrowser
//
//  Created by Andreas on 1/9/21.
//


import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
struct BrowsingView: View {
  @ObservedObject var webViewStore = WebViewStore()
    @Binding var openWeb: Bool
    @Binding var favorites: [FavWebsites]
    @Binding var points: Int
    @Binding var user: User
  var body: some View {
    ZStack {
        Color.white
    VStack {
        HStack {
        Button(action: {
            openWeb = false
        }) {
            Image(systemName: "house")
                .imageScale(.large)
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
        }
            Spacer()
            Text("\(user.points)")
        } .padding()
       
    NavigationView {
      WebView(webView: webViewStore.webView)
        .navigationBarTitle(Text(verbatim: webViewStore.webView.title ?? ""), displayMode: .inline)
        .navigationBarItems(trailing: HStack {
           
          Button(action: goBack) {
            Image(systemName: "chevron.left")
              .imageScale(.large)
              .aspectRatio(contentMode: .fit)
              .frame(width: 32, height: 32)
          }.disabled(!webViewStore.webView.canGoBack)
          Button(action: goForward) {
            Image(systemName: "chevron.right")
              .imageScale(.large)
              .aspectRatio(contentMode: .fit)
              .frame(width: 32, height: 32)
          }.disabled(!webViewStore.webView.canGoForward)
          .onChange(of: webViewStore.webView.url, perform: { value in
            for fav in favorites {
             
                if fav.isProductive {
            
                    if ((value?.absoluteString.lowercased().contains(fav.title.lowercased())) != nil) {
                        user.points += 1
                        user.date = Date()
                }
                }
            }
          })
            
        })
        
        EmptyView()
            
    }
   
    .navigationViewStyle(StackNavigationViewStyle())
  }
    }
    
  }
  func goBack() {
    webViewStore.webView.goBack()
  }
  
  func goForward() {
    webViewStore.webView.goForward()
  }
}
