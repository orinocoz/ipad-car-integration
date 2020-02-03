//
//  RemoteNotification.swift
//  Dash
//
//  Created by Yuji Nakayama on 2020/02/01.
//  Copyright © 2020 Yuji Nakayama. All rights reserved.
//

import Foundation
import DictionaryCoding

struct RemoteNotification {
    enum NotificationType: String {
        case share
    }

    let userInfo: [AnyHashable: Any]

    var type: NotificationType? {
        guard let string = userInfo["notificationType"] as? String else { return nil }
        return NotificationType(rawValue: string)
    }

    func process() throws {
        switch type {
        case .share:
            try ShareNotification(userInfo: userInfo).process()
        default:
            break
        }
    }
}

enum ItemNotificationError: Error {
    case unexpectedUserInfoStructure
}

struct ShareNotification {
    enum ItemType: String {
        case location
        case webpage
    }

    let itemDictionary: [String: Any]

    init(userInfo: [AnyHashable: Any]) throws {
        guard let itemDictionary = userInfo["item"] as? [String: Any] else {
            throw ItemNotificationError.unexpectedUserInfoStructure
        }

        self.itemDictionary = itemDictionary
    }

    var type: ItemType? {
        guard let typeString = itemDictionary["type"] as? String else { return nil }
        return ItemType(rawValue: typeString)
    }

    func process() throws {
        if let item = try decodeItem() {
            item.open()
        }
    }

    func decodeItem() throws -> SharedItem? {
        let decoder = DictionaryDecoder()

        switch type {
        case .location:
            return try decoder.decode(Location.self, from: itemDictionary)
        case .webpage:
            return try decoder.decode(Webpage.self, from: itemDictionary)
        default:
            return nil
        }
    }
}
