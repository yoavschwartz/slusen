//
//  ServerDate.swift
//  Slusen
//
//  Created by Yoav Schwartz on 19/11/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import Foundation

struct ServerDateFormatter {
    fileprivate static let dateFormatter: DateFormatter = { _ -> DateFormatter in
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    static func date(from string: String) -> Date? {
        return dateFormatter.date(from: string)
    }
}

