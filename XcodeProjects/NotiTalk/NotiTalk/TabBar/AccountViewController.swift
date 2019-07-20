//
//  AccountViewController.swift
//  NotiTalk
//
//  Created by Jane Shin on 7/18/19.
//  Copyright © 2019 Jungmin Shin. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: UIViewController {
    
    

    @IBOutlet weak var conditionsComment: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        conditionsComment.addTarget(self, action: #selector(showAlert), for: .touchUpInside)

        // Do any additional setup after loading the view.
    }
    
    @objc func showAlert(){
        
        let alertController = UIAlertController(title: "Current Status", message: nil, preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField(configurationHandler: { (textfield) in
            textfield.placeholder = "Please add current status"
        })
        alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
            
            if let textfield = alertController.textFields?.first{
                let dic = ["comment":textfield.text!]
                let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("users").child(uid!).updateChildValues(dic)
            }
            
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        
        self.present(alertController, animated: true, completion: nil)
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
