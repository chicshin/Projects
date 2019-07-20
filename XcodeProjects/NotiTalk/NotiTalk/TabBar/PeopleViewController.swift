 //
//  MainViewController.swift
//  NotiTalk
//
//  Created by Jungmin Shin on 7/11/19.
//  Copyright © 2019 Jungmin Shin. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import Kingfisher

class PeopleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var array : [UserModel] = []
    var tableview : UITableView!
//    let cellReuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview = UITableView()
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(PeopleViewTableCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableview)
        tableview.snp.makeConstraints{ (m) in
            m.top.equalTo(view)
            m.bottom.left.right.equalTo(view)
        }
        
        Database.database().reference().child("users").observe(DataEventType.value, with: { (snapshot) in
            self.array.removeAll()
            
            let myUid = Auth.auth().currentUser?.uid
            
            for child in snapshot.children{
                let fchild = child as! DataSnapshot
                let userModel = UserModel()
                userModel.setValuesForKeys(fchild.value as! [String: Any])
                if(userModel.uid == myUid){
                    continue
                }
                
                
                self.array.append(userModel)
                
            }
            
            DispatchQueue.main.async {
                self.tableview.reloadData();
            }
        })
        
        var selectFriendButton = Button()
        view.addSubview(selectFriendButton)
        selectFriendButton.snp.makeConstraints{ (m) in
            m.bottom.equalTo(view).offset(-90)
            m.right.equalTo(view).offset(-20)
            m.width.height.equalTo(50)
        }
        selectFriendButton.backgroundColor = UIColor.black
        selectFriendButton.addTarget(self, action: #selector(showSelectFriendController), for: .touchUpInside)
        selectFriendButton.layer.cornerRadius = 25
        selectFriendButton.layer.masksToBounds = true
        // Do any additional setup after loading the view.
    }
    
    @objc func showSelectFriendController(){
        self.performSegue(withIdentifier: "SelectFriendSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableview.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PeopleViewTableCell
       
        let imageview = cell.imageview!
        imageview.snp.makeConstraints{ (m) in
            m.centerY.equalTo(cell)
            m.left.equalTo(cell).offset(25)
            m.height.width.equalTo(40)
        }
        let url = URL(string: array[indexPath.row].profileImage!)
        
        imageview.layer.cornerRadius = 50/2
        imageview.clipsToBounds = true
        imageview.kf.setImage(with: url)
        
        let label = cell.label!
        label.snp.makeConstraints{ (m) in
            m.centerY.equalTo(cell)
            m.left.equalTo(imageview.snp.right).offset(20)
        }
        label.text = array[indexPath.row].username
        
        let label_comment = cell.label_comment!
        label_comment.snp.makeConstraints{ (m) in
            m.centerX.equalTo(cell.uiview_comment_background)
            m.centerY.equalTo(cell.uiview_comment_background)
            
        }
        
        if let comment = array[indexPath.row].comment{
            label_comment.text = comment
        }
        
        cell.uiview_comment_background.snp.makeConstraints{ (m) in
            m.right.equalTo(cell).offset(-10)
            m.centerY.equalTo(cell)
            if let count = label_comment.text?.count{
                m.width.equalTo(count * 10)
                
            }else{
                m.width.equalTo(0)
            }
            m.height.equalTo(30)
        }
        cell.uiview_comment_background.backgroundColor = UIColor.gray
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let view = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController
        view?.destinationUid = self.array[indexPath.row].uid
        //self.present opens new view from the bottom
        //here, use self.navigationcontroller instead
        //this slides the new view from left
        self.navigationController?.pushViewController(view!, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
 }
 
 class PeopleViewTableCell :UITableViewCell{
    
    var imageview :UIImageView! = UIImageView()
    var label :UILabel! = UILabel()
    var label_comment :UILabel! = UILabel()
    var uiview_comment_background :UIView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(imageview)
        self.addSubview(label)
        self.addSubview(uiview_comment_background)
        self.addSubview(label_comment)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 }
