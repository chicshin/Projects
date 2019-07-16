//
//  LoginViewController.swift
//  NotiTalk
//
//  Created by Jungmin Shin on 7/10/19.
//  Copyright © 2019 Jungmin Shin. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!

    let remoteconfig = RemoteConfig.remoteConfig()
    var color : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        try! Auth.auth().signOut()
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { (m) in
            m.right.top.left.equalTo(self.view)
            m.height.equalTo(40)
        }
        
        color = remoteconfig["splash_background"].stringValue
        statusBar.backgroundColor = UIColor(hex : color)
        loginButton.backgroundColor = UIColor(hex : color)
        registerButton.backgroundColor = UIColor(hex : color)
        
        loginButton.addTarget(self, action: #selector(loginEvent ), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(presentRegister), for: .touchUpInside)
        Auth.auth().addStateDidChangeListener{ (auth, user) in
            if user != nil {
                let view = self.storyboard?.instantiateViewController(withIdentifier: "MainViewTabBarController") as! UITabBarController 
                self.present(view, animated: true, completion: nil)
                let uid = Auth.auth().currentUser?.uid
                
                InstanceID.instanceID().instanceID { (token, error) in
                    if let error = error {
                        print("Error fetching remote instance ID: \(error)")
                    } else if let token = token {
                        Database.database().reference().child("users").child(uid!).updateChildValues(["pushtoken":token.token])
                    }
                }
            }
        }

        // Do any additional setup after loading the view.
    }
    
    @objc func loginEvent(){
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (user, err) in
            if err != nil {
                let alert = UIAlertController(title: "Error", message: err.debugDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @objc func presentRegister(){
        let view = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        self.present(view, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
