//
//  RealmUser.swift
//  MeraAssignment
//
//  Created by NhatMinh on 27/11/24.
//

import RealmSwift

class RealmUser: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var login: String
    @Persisted var location: String?
    @Persisted var followers: Int?
    @Persisted var following: Int?
    @Persisted var nodeID: String
    @Persisted var avatarURL: String
    @Persisted var gravatarID: String
    @Persisted var url: String
    @Persisted var htmlURL: String
    @Persisted var followersURL: String
    @Persisted var followingURL: String
    @Persisted var gistsURL: String
    @Persisted var starredURL: String
    @Persisted var subscriptionsURL: String
    @Persisted var organizationsURL: String
    @Persisted var reposURL: String
    @Persisted var eventsURL: String
    @Persisted var receivedEventsURL: String
    @Persisted var type: String
    @Persisted var userViewType: String
    @Persisted var siteAdmin: Bool
    @Persisted var blog: String?

    // Convenience initializer
    convenience init(from user: User) {
        self.init()
        self.id = user.id
        self.login = user.login
        self.location = user.location
        self.followers = user.followers
        self.following = user.following
        self.nodeID = user.nodeID
        self.avatarURL = user.avatarURL
        self.gravatarID = user.gravatarID
        self.url = user.url
        self.htmlURL = user.htmlURL
        self.followersURL = user.followersURL
        self.followingURL = user.followingURL
        self.gistsURL = user.gistsURL
        self.starredURL = user.starredURL
        self.subscriptionsURL = user.subscriptionsURL
        self.organizationsURL = user.organizationsURL
        self.reposURL = user.reposURL
        self.eventsURL = user.eventsURL
        self.receivedEventsURL = user.receivedEventsURL
        self.type = user.type
        self.userViewType = user.userViewType
        self.siteAdmin = user.siteAdmin
        self.blog = user.blog
    }
}


extension RealmUser {
    func toUser() -> User {
        return User(
            login: login,
            id: id,
            location: location,
            followers: followers,
            following: following,
            nodeID: nodeID,
            avatarURL: avatarURL,
            gravatarID: gravatarID,
            url: url,
            htmlURL: htmlURL,
            followersURL: followersURL,
            followingURL: followingURL,
            gistsURL: gistsURL,
            starredURL: starredURL,
            subscriptionsURL: subscriptionsURL,
            organizationsURL: organizationsURL,
            reposURL: reposURL,
            eventsURL: eventsURL,
            receivedEventsURL: receivedEventsURL,
            type: type,
            userViewType: userViewType,
            siteAdmin: siteAdmin,
            blog: blog
        )
    }
}
