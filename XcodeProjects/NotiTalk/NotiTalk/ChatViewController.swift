//
//  ChatViewController.swift
//  NotiTalk
//
//  Created by Jungmin Shin on 7/12/19.
//  Copyright © 2019 Jungmin Shin. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    
    @IBOutlet weak var bottomContraint: NSLayoutConstraint!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textfield_message: UITextField!
    
    
    var uid :String?
    var chatRoomUid :String?
    
    var comments : [ChatModel.Comment] = []
    var userModel : UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uid = Auth.auth().currentUser?.uid
        sendButton.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
        checkChatRoom()
        self.tabBarController?.tabBar.isHidden = true
        
        let tap :UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        
        if let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            self.bottomContraint.constant = keyboardSize.height
        }
        
        UIView.animate(withDuration: 0, animations: {
        self.view.layoutIfNeeded()
        }, completion: {
        (complete) in
            if self.comments.count > 0{
                self.tableview.scrollToRow(at: IndexPath(item:self.comments.count-1, section:0), at: UITableView.ScrollPosition.bottom, animated: true)
            }
        })
    }
    
    @objc func keyboardWillHide(notification: Notification){
        self.bottomContraint.constant = 20
        self.view.layoutIfNeeded()
    }
    
    //hide keyboard with tap on background
    @objc func dismissKeyboard(){
        
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(self.comments[indexPath.row].uid == uid){
        
            let view = tableview.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MyMessageCell
            view.label_message.text = self.comments[indexPath.row].message
            view.label_message.numberOfLines = 0;
            
            if let time = self.comments[indexPath.row].timestamp{
                view.label_timestamp.text = time.toDayTime
            }
            return view
        }else{
            let view = tableView.dequeueReusableCell(withIdentifier: "DestinationMessageCell", for: indexPath) as! DestinationMessageCell
            view.label_name.text = userModel?.username
            view.label_message.text = self.comments[indexPath .row].message
            view.label_message.numberOfLines = 0;
            
            let url = URL(string:(self.userModel?.profileImage)!)
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, err) in
                DispatchQueue.main.async {
                    view.imageview_profile.image = UIImage(data: data!)
                    view.imageview_profile.layer.cornerRadius = view.imageview_profile.frame.width/2
                    view.imageview_profile.clipsToBounds = true
                }
            }).resume()
            
            if let time = self.comments[indexPath.row].timestamp{
                view.label_timestamp.text = time.toDayTime
            }
            return view
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    public var destinationUid : String? //counter users uid
    
    @objc func createRoom(){
        let createRoomInfo : Dictionary<String,Any> = ["users":[
            uid!: true,
            destinationUid! :true
            ]
        ]
        
        let value :Dictionary<String,Any> = [
            "uid" : uid!,
            "message" : textfield_message.text!,
            "timestamp" : ServerValue.timestamp()
        
        ]
        
        if(chatRoomUid == nil){
            //disable creating multiple chatrooms while creating the first one
            self.sendButton.isEnabled = false
            // 방 생성 코드
            Database.database().reference().child("chatrooms").childByAutoId().setValue(createRoomInfo, withCompletionBlock: {(err, ref) in
                if(err == nil){
                    
                    self.checkChatRoom()
                }
            })
        }else{
            
            Database.database().reference().child("chatrooms").child(chatRoomUid!).child("comments").childByAutoId().setValue(value, withCompletionBlock: { (err, ref) in
                self.textfield_message.text = ""
            })
        }
        
    }
    
    //avoid duplicate chatrooms
    func checkChatRoom(){
        
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid!).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value,with: { (datasnapshot) in
            for item in datasnapshot.children.allObjects as! [DataSnapshot]{
                
                if let chatRoomdic = item.value as? [String:AnyObject]{
                    let chatModel = ChatModel(JSON: chatRoomdic)
                    if(chatModel?.users[self.destinationUid!] == true){
                            self.chatRoomUid = item.key
                        self.sendButton.isEnabled = true
                        self.getDestinationInfo()
                    }
                }
                
                self.chatRoomUid = item.key
                
            }
        })
    }
    
    func getDestinationInfo(){
        
        Database.database().reference().child("users").child(self.destinationUid!).observeSingleEvent(of: DataEventType.value, with: { (datasnapshot) in
            self.userModel = UserModel()
            self.userModel?.setValuesForKeys(datasnapshot.value as! [String:Any])
            self.getMeassageList()
        })
    }
    func getMeassageList(){
        Database.database().reference().child("chatrooms").child(self.chatRoomUid!).child("comments").observe(DataEventType.value, with: { (datasnapshot) in
            self.comments.removeAll()
            for item in datasnapshot.children.allObjects as! [DataSnapshot]{
                let comment = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                self.comments.append(comment!)
                
            }
            self.tableview.reloadData()
            
            if self.comments.count > 0{
                self.tableview.scrollToRow(at: IndexPath(item:self.comments.count-1, section:0), at: UITableView.ScrollPosition.bottom, animated: true)
            }
            
            
        })
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


extension Int{
    
    var toDayTime :String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let date = Date(timeIntervalSince1970: Double(self)/1000)
        
        return dateFormatter.string(from: date)
    }
}
class MyMessageCell :UITableViewCell{
    
    @IBOutlet weak var label_message: UILabel!
    
    @IBOutlet weak var label_timestamp: UILabel!
    
    
}

class DestinationMessageCell :UITableViewCell{
    

    @IBOutlet weak var label_message: UILabel!
    
    @IBOutlet weak var imageview_profile: UIImageView!

    @IBOutlet weak var label_name: UILabel!
    
    @IBOutlet weak var label_timestamp: UILabel!
}
