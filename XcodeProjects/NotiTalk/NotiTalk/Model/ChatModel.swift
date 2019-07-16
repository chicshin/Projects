//
//  ChatModel.swift
//  NotiTalk
//
//  Created by Jungmin Shin on 7/12/19.
//  Copyright © 2019 Jungmin Shin. All rights reserved.
//

import ObjectMapper

class ChatModel: Mappable {
    
    
    public var users : Dictionary<String,Bool> = [:] //users involved in the chatroom
    public var comments :Dictionary<String,Comment> = [:]
    required init?(map: Map) {

    }
    
    func mapping(map: Map) {
        users <- map["users"]
        comments <- map["comments"]
    }
    
    public class Comment:Mappable{
        public var uid :String?
        public var message :String?
        public var timestamp :Int?
        public required init?(map: Map) {
            
        }
        public func mapping(map: Map) {
            uid <- map["uid"]
            message <- map["message"]
            timestamp <- map["timestamp"]
        }
    }
}
