//
//  User.swift
//  ToDoFire
//
//  Created by User on 03.10.2023.
//

import Foundation
import Firebase

struct Client {
    
    let uid: String
    let email: String
    
    init(client: User) {
        self.uid = client.uid
        self.email = client.email!
    }
}
