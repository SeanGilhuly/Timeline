//
//  SearchableRecord.swift
//  Timeline
//
//  Created by Sean Gilhuly on 6/14/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation

@objc protocol SearchableRecord {
    func matchesSearchTerm(searchTerm: String) -> Bool
}