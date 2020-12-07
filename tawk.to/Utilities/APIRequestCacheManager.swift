//
//  APIRequestCacheManager.swift
//  tawk.to
//
//  Created by Dominic Valencia on 12/5/20.
//  Copyright © 2020 Dominic Valencia. All rights reserved.
//

import Foundation

public class APIRequestCacheManager {
    static let time: Int = 5 // n minutes
    
    static func fileCacheKeyCreator(from key: String) -> String {
        return "\(key)"
    }
    
    public class func forceClear(_ key: String) {
        let cache = JSONFileCache(name: APIRequestCacheManager.fileCacheKeyCreator(from: key))
        cache.clear()
    }
    
    public class func shouldGetCache(_ key: String, _ noCache: Bool = false, complete: @escaping ((Bool, Data?) -> ())) {
        let cache = JSONFileCache(name: APIRequestCacheManager.fileCacheKeyCreator(from: key))
        let currentCacheTime = NSDate()
        let cacheTime = cache.getfileCreatedDate()
        let elapsedTime = (Int(currentCacheTime.timeIntervalSince(cacheTime)) % 3600) / 60
        if !noCache, elapsedTime < time, let data = cache.read() {
            complete(true, data)
            
        } else {
            cache.clear()
            complete(false, nil)
        }
        
    }
    
    public class func cacheData(_ data: Data, withKey key: String) {
        JSONFileCache(name: APIRequestCacheManager.fileCacheKeyCreator(from: key)).write(data: data)
    }
    
    public class func removeCacheData(_ key: String) {
        JSONFileCache(name: APIRequestCacheManager.fileCacheKeyCreator(from: key)).clear()
    }
}


