//
//  Channel.swift
//  youtube-clone
//
//  Created by Yaku on 17/08/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import Foundation

struct Channel: Decodable {
    let items: [ChannelInfo]
}

struct ChannelInfo: Decodable {
    let id: String
    let snippet: ChannelSnippet
}

struct ChannelSnippet: Decodable {
    let thumbnails: Thumbnail
}
