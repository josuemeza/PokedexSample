//
//  Pokemon.swift
//  dex
//
//  Created by Josue Meza on 12/12/18.
//  Copyright © 2018 Josue Meza. All rights reserved.
//

import Foundation
import SwiftyJSON
import PromiseKit

class Pokemon {
    
    // MARK: - Definitions
    
    typealias ListItem = (name: String, url: String)
    static let apiUrl = "https://pokeapi.co/api/v2"
    
    // MARK: - Attributes
    
    private(set) var id: Int = -1
    private(set) var name: String?
    private(set) var firstType: String?
    private(set) var secondType: String?
    private(set) var spriteUrl: URL?
    
    // MARK: - Init methods
    
    private init() {}
    
    private init?(json: JSON) {
        guard let id = json["id"].int else { return nil }
        let unsortedTypes = json["types"].array ?? []
        let sortedTypes = unsortedTypes.sorted { left, right in
            left["slot"].intValue < right["slot"].intValue
        }
        self.id = id
        name = json["name"].string?.capitalized
        firstType = sortedTypes.first?["type"]["name"].string
        secondType = sortedTypes.count > 1 ? sortedTypes[1]["type"]["name"].string : nil
        spriteUrl = URL(string: json["sprites"]["front_default"].string ?? "")
    }
    
}

// MARK: -
extension Pokemon {
    
    // MARK: - Pokemon requests
    
    static func list() -> Promise<[ListItem]> {
        return Promise { seal in
            Alamofire.request("\(apiUrl)/pokemon").responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let results = json["results"].array ?? []
                    let pokemons = results.compactMap { element in (name: element["name"].stringValue, url: element["url"].stringValue) }
                    seal.fulfill(pokemons)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    static func fetch(_ listItem: Pokemon.ListItem) -> Promise<Pokemon> {
        return Promise { seal in
            Alamofire.request(listItem.url).responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if let pokemon = Pokemon(json: json) {
                        seal.fulfill(pokemon)
                    } else {
                        seal.reject(NSError(domain: "Missigno", code: 5000, userInfo: nil))
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
}

// MARK: -
extension Pokemon {
    
    class PokemonType {
        
        // MARK: - Pokemon type color
        
        private static var pokemonTypeColor: [String: UIColor] = [
            "normal": UIColor(red: 168/255, green: 168/255, blue: 120/255, alpha: 1),
            "fire": UIColor(red: 240/255, green: 128/255, blue: 48/255, alpha: 1),
            "water": UIColor(red: 104/255, green: 144/255, blue: 240/255, alpha: 1),
            "grass": UIColor(red: 120/255, green: 200/255, blue: 80/255, alpha: 1),
            "electric": UIColor(red: 248/255, green: 208/255, blue: 48/255, alpha: 1),
            "ice": UIColor(red: 152/255, green: 216/255, blue: 216/255, alpha: 1),
            "fighting": UIColor(red: 192/255, green: 48/255, blue: 40/255, alpha: 1),
            "poison": UIColor(red: 160/255, green: 64/255, blue: 160/255, alpha: 1),
            "ground": UIColor(red: 224/255, green: 192/255, blue: 104/255, alpha: 1),
            "flying": UIColor(red: 168/255, green: 144/255, blue: 240/255, alpha: 1),
            "psychic": UIColor(red: 248/255, green: 88/255, blue: 136/255, alpha: 1),
            "bug": UIColor(red: 168/255, green: 184/255, blue: 32/255, alpha: 1),
            "rock": UIColor(red: 184/255, green: 160/255, blue: 56/255, alpha: 1),
            "ghost": UIColor(red: 112/255, green: 88/255, blue: 152/255, alpha: 1),
            "dark": UIColor(red: 112/255, green: 88/255, blue: 72/255, alpha: 1),
            "dragon": UIColor(red: 112/255, green: 56/255, blue: 248/255, alpha: 1),
            "steel": UIColor(red: 184/255, green: 184/255, blue: 208/255, alpha: 1),
            "fairy": UIColor(red: 240/255, green: 182/255, blue: 188/255, alpha: 1)
        ]
        
        static func color(for type: String) -> UIColor? {
            return pokemonTypeColor[type]
        }
        
    }
    
}
