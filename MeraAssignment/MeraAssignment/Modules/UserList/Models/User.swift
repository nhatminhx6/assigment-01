//
//  Repository.swift
//  MeraAssignment
//
//  Created by NhatMinh on 23/11/24.
//

import Foundation

// The Repository model
//struct User: Codable {
//    let fullName: String
//    let description: String
//    let starsCount: Int?
//    let url: String
//
//    enum CodingKeys: String, CodingKey {
//
//        case fullName = "full_name"
//        case starsCount
//        case description
//        case url
//    }
//}

struct User: Codable {
    let login: String
    let id: Int
    let nodeID: String
    let avatarURL: String
    let gravatarID: String
    let url: String
    let htmlURL: String
    let followersURL: String
    let followingURL: String
    let gistsURL: String
    let starredURL: String
    let subscriptionsURL: String
    let organizationsURL: String
    let reposURL: String
    let eventsURL: String
    let receivedEventsURL: String
    let type: String
    let userViewType: String
    let siteAdmin: Bool
    //--
    let fullName: String?
    let description: String?
    let starsCount: Int?

    // Coding keys for custom mapping
    enum CodingKeys: String, CodingKey {
        case login, id
        case nodeID = "node_id"
        case avatarURL = "avatar_url"
        case gravatarID = "gravatar_id"
        case url
        case htmlURL = "html_url"
        case followersURL = "followers_url"
        case followingURL = "following_url"
        case gistsURL = "gists_url"
        case starredURL = "starred_url"
        case subscriptionsURL = "subscriptions_url"
        case organizationsURL = "organizations_url"
        case reposURL = "repos_url"
        case eventsURL = "events_url"
        case receivedEventsURL = "received_events_url"
        case type
        case userViewType = "user_view_type"
        case siteAdmin = "site_admin"
        
        //--
        case fullName = "full_name"
        case starsCount
        case description
    }
}
