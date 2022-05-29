//
//  Product.swift
//  ArbuzShop
//
//  Created by Dana on 29.05.2022.
//

import Foundation

struct Product: Identifiable {
    var id = UUID()
    var name: String
    var image : String
    var price : Int
    
}

var productList = [ Product( name: "Спелый", image: "appstore", price: 400 ),
                   Product( name: "НеСпелый", image: "appstore-2", price: 350 ),
                   Product( name: "Уже сорван", image: "appstore-1", price: 300 ),]
