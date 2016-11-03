//
//  JSONDecodable.swift
//  Slusen
//
//  Created by Yoav Schwartz on 29/10/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import Foundation

protocol JSONDecodable {
    init(json: [String: Any])
}
