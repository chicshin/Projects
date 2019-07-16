//
//  RegisterViewController.swift
//  NotiTalk
//
//  Created by Jungmin Shin on 7/10/19.
//  Copyright © 2019 Jungmin Shin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase


class RegisterViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {


    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var register: UIButton!
    @IBOutlet weak var cancle: UIButton!
    
    let remoteconfig = RemoteConfig.remoteConfig()
    var color : String? 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { (m) in
            m.right.top.left.equalTo(self.view)
            m.height.equalTo(40)
        }
        color = remoteconfig["splash_background"].stringValue
        statusBar.backgroundColor = UIColor(hex : color!)
//        register.backgroundColor = UIColor(hex : color!)
//        cancle.backgroundColor = UIColor(hex : color!)
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imagePicker)))
        
        cancle.addTarget(self, action: #selector(cancleEvent), for: .touchUpInside)
        register.addTarget(self, action: #selector(registerEvent), for: .touchUpInside)

        // Do any additional setup after loading the view.
    }
    
    @objc func imagePicker(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary

        self.present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]){

        let selectedImage = info[.originalImage] as! UIImage

        imageView.image = selectedImage

        dismiss(animated: true, completion: nil)
    }
    
    @objc func registerEvent() {
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user, err) in
            if err == nil && user != nil {
                print("user created")
            }else {
                print("sign up failed")
            }
            guard let userID = Auth.auth().currentUser?.uid else{
                return
            }
            
            let image = self.imageView.image?.jpegData(compressionQuality: 0.1)
            let storageRef = Storage.storage().reference()
            let storageProfileRef = storageRef.child("userImage").child(userID)
            let metadata = StorageMetadata()
            metadata.contentType = "Image/jpg"
            
            storageProfileRef.putData(image!, metadata: metadata, completion: {(storageMetaData, err) in
                if err != nil {
                    print("upload failed")
                    return
                }
                storageProfileRef.downloadURL(completion: {(url, err) in
                    let metaImageUrl = url?.absoluteString
                    let values = ["username":self.name.text!,"profileImage":metaImageUrl, "uid":Auth.auth().currentUser?.uid]
                    
                    Database.database().reference().child("users").child(userID).setValue(values, withCompletionBlock: { (err, ref) in
                        if(err == nil) {
                            self.cancleEvent()
                        }
                    })
                })
            })
        }
    }
    

    
    @objc func cancleEvent(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
