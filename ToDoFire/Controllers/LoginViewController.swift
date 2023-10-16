//
//  ViewController.swift
//  ToDoFire
//
//  Created by User on 01.10.2023.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    let segueIdentifier = "tasksSegue"
    var ref: DatabaseReference!
    
    @IBOutlet weak var warnLabel: UILabel!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference(withPath: "users")
        
        NotificationCenter.default.addObserver(self, selector: #selector(kbDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        warnLabel.alpha = 0
        
        Auth.auth().addStateDidChangeListener( { [weak self] (auth, user) in
            if user != nil {
                self?.performSegue(withIdentifier: (self?.segueIdentifier)!, sender: nil)
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTF.text = ""
        passwordTF.text = ""
    }
    
    @objc func kbDidShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let kbFrameSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        (self.view as! UIScrollView).contentSize = CGSize(
            width: self.view.bounds.width,
            height: self.view.bounds.height + kbFrameSize.height
        )
        
        (self.view as! UIScrollView).scrollIndicatorInsets = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: kbFrameSize.height,
            right: 0
        )
    }
    
    @objc func kbDidHide() {
        (self.view as? UIScrollView)?.contentSize = CGSize(
            width: self.view.bounds.width,
            height: self.view.bounds.height
        )
    }
    
    func dispalayWarnLabel(withText text: String) {
        warnLabel.text = text
        
        UIView.animate(
            withDuration: 3,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1,
            options: .curveEaseOut, animations: { [weak self] in
                self?.warnLabel.alpha = 1
            }) { [weak self] complete in
                self?.warnLabel.alpha = 0
            }
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        guard let email = emailTF.text, let password = passwordTF.text, email != "", password != "" else {
            dispalayWarnLabel(withText: "Info is incorrect")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] (user, error) in
            if error != nil {
                self?.dispalayWarnLabel(withText: "Error occured")
                return
            }
            if user != nil {
                self?.performSegue(withIdentifier: "tasksSegue", sender: nil)
                return
            }
            self?.dispalayWarnLabel(withText: "No such user")
        })
    }
    
    @IBAction func registerTapped(_ sender: UIButton) {
        guard let email = emailTF.text, let password = passwordTF.text, email != "", password != "" else {
            dispalayWarnLabel(withText: "Info is incorrect")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] (user, error) in
            guard error == nil, user != nil else {
                print(error?.localizedDescription)
                return
            }
            let userRef = self?.ref.child((user?.user.uid)!)
            userRef?.setValue(["email" : user?.user.email])
        })
    }
}
