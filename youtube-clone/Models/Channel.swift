//
//  Channel.swift
//  youtube-clone
//
//  Created by Yaku on 17/08/2020.
//  Copyright © 2020 Uppercaseme. All rights reserved.
//

import Foundation

struct Channel: Decodable {
    let items: [ChannelItem]
}

struct ChannelItem: Decodable {
    let id: String
    var snippet: ChannelSnippet
}

struct ChannelSnippet: Decodable {
    var thumbnails: Thumbnail
}
