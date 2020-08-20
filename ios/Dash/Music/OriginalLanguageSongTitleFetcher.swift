//
//  OriginalSongTitleFetcher.swift
//  Dash
//
//  Created by Yuji Nakayama on 2020/07/27.
//  Copyright © 2020 Yuji Nakayama. All rights reserved.
//

import Foundation
import AppleMusic
import PINCache

class OriginalLanguageSongTitleFetcher {
    enum LanguageTag: String {
        case ja = "ja"
        case enUS = "en-US"
    }

    static let cache = PINCache(
        name: "OriginalLanguageSongTitleFetcher",
        rootPath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!,
        serializer: nil,
        deserializer: nil,
        keyEncoder: nil,
        keyDecoder: nil,
        ttlCache: true
    )

    private let cacheAgeLimit: TimeInterval = 60 * 60 * 24 * 30 * 6 // 6 months

    let appleMusicClient: AppleMusic

    init(storefront: Storefront, developerToken: String) {
        appleMusicClient = AppleMusic(storefront: storefront, developerToken: developerToken)
    }

    func originalLanguageSong(id: String, completionHandler: @escaping (Result<OriginalLanguageSong, Error>) -> Void) {
        if let cachedSong = cachedSong(id: id) {
            logger.debug(cachedSong)
            completionHandler(.success(cachedSong))
            return
        }

        fetchOriginalLanguageSong(id: id, completionHandler: completionHandler)
    }

    private func fetchOriginalLanguageSong(id: String, in language: LanguageTag? = nil, completionHandler: @escaping (Result<OriginalLanguageSong, Error>) -> Void) {
        let requestLanguage = language ?? LanguageTag.enUS

        fetchSong(id: id, in: requestLanguage) { [weak self] (result) in
            guard let self = self else { return }

            logger.debug(result)

            switch result {
            case .success(let songAttributes):
                let originalLanguage = self.originalLanguage(of: songAttributes)

                if originalLanguage == requestLanguage {
                    let song = OriginalLanguageSong(title: songAttributes.name, artist: songAttributes.artistName, isrc: songAttributes.isrc)
                    self.cache(song: song, for: id)
                    completionHandler(.success(song))
                } else {
                    self.fetchOriginalLanguageSong(id: id, in: originalLanguage, completionHandler: completionHandler)
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }

    private func fetchSong(id: String, in language: LanguageTag, completionHandler: @escaping (Result<SongAttributes, Error>) -> Void) {
        appleMusicClient.song(id: id, language: language.rawValue) { (song, error) in
            if let error = error {
                completionHandler(.failure(error))
                return
            }

            if let songAttributes = song?.attributes {
                completionHandler(.success(songAttributes))
            }
        }
    }

    private func cachedSong(id: String) -> OriginalLanguageSong? {
        return OriginalLanguageSongTitleFetcher.cache.object(forKey: id) as? OriginalLanguageSong
    }

    private func cache(song: OriginalLanguageSong, for id: String) {
        OriginalLanguageSongTitleFetcher.cache.setObjectAsync(song, forKey: id, withAgeLimit: cacheAgeLimit)
    }

    private func originalLanguage(of song: SongAttributes) -> LanguageTag {
        let countryCode = song.isrc.prefix(2)

        switch countryCode {
        case "JP":
            return .ja
        default:
            return .enUS
        }
    }
}

class OriginalLanguageSong: NSObject, NSCoding {
    enum CodingKey: String {
        case title
        case artist
        case isrc
    }

    let title: String
    let artist: String
    let isrc: String

    init(title: String, artist: String, isrc: String) {
        self.title = title
        self.artist = artist
        self.isrc = isrc
    }

    required init?(coder: NSCoder) {
        guard let title = coder.decodeObject(forKey: CodingKey.title.rawValue) as? String else { return nil }
        self.title = title

        guard let artist = coder.decodeObject(forKey: CodingKey.artist.rawValue) as? String else { return nil }
        self.artist = artist

        guard let isrc = coder.decodeObject(forKey: CodingKey.isrc.rawValue) as? String else { return nil }
        self.isrc = isrc
    }

    func encode(with coder: NSCoder) {
        coder.encode(title, forKey: CodingKey.title.rawValue)
        coder.encode(artist, forKey: CodingKey.artist.rawValue)
        coder.encode(isrc, forKey: CodingKey.isrc.rawValue)
    }
}
