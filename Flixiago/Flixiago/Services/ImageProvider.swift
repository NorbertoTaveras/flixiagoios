//
//  ImageProvider.swift
//  Flixiago
//
//  Created by Norberto Taveras on 12/16/19.
//  Copyright © 2019 Norberto Taveras. All rights reserved.
//

import Foundation

public protocol ImageProvider {
    func getImageUrl() -> String?
    func getImageCaption() -> String?
    func getImageRating() -> Float?
}
