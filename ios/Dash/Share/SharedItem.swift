//
//  SharedItem.swift
//  Dash
//
//  Created by Yuji Nakayama on 2020/02/01.
//  Copyright © 2020 Yuji Nakayama. All rights reserved.
//

import Foundation
import DictionaryCoding
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol SharedItemProtocol: Decodable {
    var creationDate: Date? { get }
    func open()
}

enum SharedItemError: Error {
    case invalidDictionaryStructure
}

struct SharedItem {
    enum ItemType: String {
        case location
        case webpage
        case unknown

        static func makeType(dictionary: [String: Any]) throws -> ItemType {
            guard let typeString = dictionary["type"] as? String else {
                throw SharedItemError.invalidDictionaryStructure
            }

            return ItemType(rawValue: typeString) ?? .unknown
        }
    }

    static func makeItem(document: QueryDocumentSnapshot) throws -> SharedItemProtocol {
        let dictionary = document.data()
        let type = try ItemType.makeType(dictionary: dictionary)
        let decoder = Firestore.Decoder() // Supports decoding Firestore's Timestamp

        switch type {
        case .location:
            return try decoder.decode(Location.self, from: dictionary)
        case .webpage:
            return try decoder.decode(Webpage.self, from: dictionary)
        case .unknown:
            return try decoder.decode(UnknownItem.self, from: dictionary)
        }
    }

    static func makeItem(dictionary: [String: Any]) throws -> SharedItemProtocol {
        let type = try ItemType.makeType(dictionary: dictionary)
        let decoder = DictionaryDecoder()

        switch type {
        case .location:
            return try decoder.decode(Location.self, from: dictionary)
        case .webpage:
            return try decoder.decode(Webpage.self, from: dictionary)
        case .unknown:
            return try decoder.decode(UnknownItem.self, from: dictionary)
        }
    }
}
