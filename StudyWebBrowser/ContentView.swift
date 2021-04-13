//
//  ContentView.swift
//  StudyWebBrowser
//
//  Created by Andreas on 1/9/21.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine
struct ContentView: View {
    @State var webViewStore = WebViewStore()
    @State var webViewStores = [WebViewStore(), WebViewStore(), WebViewStore(), WebViewStore()]
   
    @State var openWeb = false
    var vGridLayout = [ GridItem(.adaptive(minimum: 150, maximum: 1000)), GridItem(.adaptive(minimum: 150, maximum: 1000))]
    @State var favorites = [FavWebsites(id: UUID().uuidString, title: "Quizlet", website: "https://quizlet.com", isProductive: true), FavWebsites(id: UUID().uuidString,  title: "Albert", website: "https://albert.io", isProductive: true)]
    @State var searchText = ""
    @State var points = 0
    @State var users = [User]()
    @State var pointz = [Int]()
    @State var edit = false
    @State var id = UserDefaults.standard.string(forKey: "id") ?? UUID().uuidString
    @State var first = UserDefaults.standard.bool(forKey: "first")
    @State var websites = UserDefaults.standard.stringArray(forKey: "websites") ?? ["https://quizlet.com", "https://albert.io"]
    @State var user = User(id: "", name: "", points: 0, date: Date())
    @State var currentHeight: CGFloat = 0
    var body: some View {
        ZStack {
            Color.white
                
                .onAppear() {
                   
                    if !first {
                        edit = true
                        let defaults = UserDefaults.standard
                        defaults.set(id, forKey: "id")
                       
                    }
                    user.id = id
                    self.loadToday() { userData in
                        
                        users.removeAll()
                        
                            self.users = userData ?? []
                        for i in users.indices {
                            if users[i].id == id {
                                user = users[i]
                            }
                            let components = Date().get(.day, .month, .year)
                            let components2 = users[i].date.get(.day, .month, .year)
                            if let today = components2.day, let month = components.month, let year = components.year {
                            if let today2 = components.day, let month2 = components.month, let year2 = components.year {
                               
                            
                            if "\(today)" + "\(month)" + "\(year)" != "\(today2)" + "\(month2)" + "\(year2)" {
                                users[i].points = 0
                                if users[i].id == id {
                                user.points = 0
                                }
                                let db = Firestore.firestore()
                                let ref = db.collection("users").document(users[i].id)
                                do{
                                    try ref.setData(from: users[i])
                                }
                                catch{
                                    print("Error saving data, \(error)")
                                }
                            }
                            }
                            }
                            
                        }
                        
                       
                    }
                   
                    for i in websites.indices {
                           
                            webViewStores[i].webView.load(URLRequest(url: URL(string: websites[i])!))
                        }
                    let defaults = UserDefaults.standard
                    defaults.set(true, forKey: "first")
                }
            VStack {
                HStack {
                    
                    Button(action: {
                        edit = true
                    }) {
                        Text("Edit")
                            .padding()
                    }
                    Spacer()
                    Text("\(user.points)")
                    
                }
                SearchBarView(searchText: $searchText, openWeb: $openWeb, webViewStore: $webViewStore)
                Spacer()
            LazyVGrid(columns: vGridLayout) {
                ForEach(websites.indices, id: \.self) { i in
            Button(action: {
                webViewStore = webViewStores[i]
                openWeb = true
            }) {
                ZStack {
                    Text(websites[i])
                    .font(.title)
                        .padding()
                        .background(BlurView(style: .systemUltraThinMaterialLight))
                        .shadow(color: Color("Primary").opacity(0.1), radius: 15)
                        .shadow(color: Color("Primary").opacity(0.2), radius: 25, x: 0, y: 20)
                        .clipShape(RoundedRectangle(cornerRadius: 25.0))
                }
            }
                }
            }
                ForEach(users, id: \.self) { user in
                    HStack {
                    Text(user.name)
                        .font(.headline)
                        .padding()
                        Spacer()
                    Text(String(user.points))
                        .font(.headline)
                        .padding()
                    }
                }
            
            } .padding()
            .onChange(of: user, perform: { value in
                for i in users.indices {
                    if users[i].id == id {
                        users[i] = user
                    }
                }
            })
            .sheet(isPresented: $edit, content: {
                VStack {
                    HStack {
                        Button(action: {
                            edit = false
                        }) {
                            Image(systemName: "xmark")
                                .padding()
                        }
                        Spacer()
                        
                        
                    }
                    TextField("Name", text: $user.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    HStack {
                    TextField("Website", text: $websites[websites.count - 1])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Button(action: {
                        
                        websites.append("")
                    }) {
                        Circle()
                            .frame(width: 75, height: 75, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    }
                    }
                } .onDisappear() {
                   
                    let db = Firestore.firestore()
                    do {
                    try db.collection("users").document(id).setData(from: user, merge: true) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                    
                    } catch {
                    }
                    }
            })
        if openWeb {
            BrowsingView(webViewStore: webViewStore, openWeb: $openWeb, favorites: $favorites, points: $points, user: $user)
                .onDisappear() {
                    let db = Firestore.firestore()
                    let ref = db.collection("users").document(user.id)
                    do{
                        try ref.setData(from: user)
                    }
                    catch{
                        print("Error saving data, \(error)")
                    }
                }
        }
    }
        
    }
    
    private func subscribeToKeyboardEvents() {
      NotificationCenter.Publisher(
        center: NotificationCenter.default,
        name: UIResponder.keyboardWillShowNotification
      ).compactMap { notification in
          notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect
      }.map { rect in
        rect.height
      }.subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))

      NotificationCenter.Publisher(
        center: NotificationCenter.default,
        name: UIResponder.keyboardWillHideNotification
      ).compactMap { notification in
        CGFloat.zero
        
      }.subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))
    }
    
    func loadToday(performAction: @escaping ([User]?) -> Void) {
           let db = Firestore.firestore()
        let docRef = db.collection("users")
           var groupList:[User] = []
           //Get every single document under collection users
        let day = Date().timeIntervalSince1970 - 86400
        //let queryParameter = docRef.whereField("date", isGreaterThan: day)
        docRef.getDocuments{ (querySnapshot, error) in
               if let querySnapshot = querySnapshot,!querySnapshot.isEmpty{
               for document in querySnapshot.documents{
                   let result = Result {
                       try document.data(as: User.self)
                   }
                   switch result {
                       case .success(let group):
                           if var group = group {
 
                               groupList.append(group)
                            //print(group.name)
                           } else {
                               
                               print("Document does not exist")
                           }
                       case .failure(let error):
                           print("Error decoding user: \(error)")
                       }
                   
                 
               }
               }
               else{
                   performAction(nil)
               }
                 performAction(groupList)
           }
           
           
       }
}


