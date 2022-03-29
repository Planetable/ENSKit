//
//  HTTPURLResponse+Extension.swift
//
//
//  Created by Shu Lyu on 2022-03-27.
//

import Foundation

extension HTTPURLResponse {
    var ok: Bool {
        return self.statusCode >= 200 && self.statusCode < 300
    }
}
