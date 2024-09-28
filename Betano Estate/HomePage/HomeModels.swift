//
//  HomeModels.swift
//  Betano Estate
//
//  Created by Владимир Кацап on 26.09.2024.
//

import Foundation

struct Home: Codable {
    var isLike: Bool
    var name: String
    var status: String
    var description: String
    var price: String
    var size: String
    var location: String
    var propertyType: String
    var annualReturn: String
    var occupancyRate: String
    var photos: [Data]
    
    init(isLike: Bool, name: String, status: String, description: String, price: String, size: String, location: String, propertyType: String, annualReturn: String, occupancyRate: String, photos: [Data]) {
        self.isLike = isLike
        self.name = name
        self.status = status
        self.description = description
        self.price = price
        self.size = size
        self.location = location
        self.propertyType = propertyType
        self.annualReturn = annualReturn
        self.occupancyRate = occupancyRate
        self.photos = photos
    }
}


struct transactions: Codable {
    var property: String
    var location: String
    var tupe: String
    var amount: String
    
    init(property: String, location: String, tupe: String, amount: String) {
        self.property = property
        self.location = location
        self.tupe = tupe
        self.amount = amount
    }
}
