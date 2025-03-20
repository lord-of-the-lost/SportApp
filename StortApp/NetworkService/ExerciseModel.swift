//
//  ExerciseModel.swift
//  StortApp
//
//  Created by Николай Игнатов on 20.03.2025.
//


import Foundation

struct ExerciseModel: Codable {
    let name: String
    let type: String
    let muscle: String
    let equipment: String
    let difficulty: String
    let instructions: String
}

struct ExerciseQueryParameters {
    let name: String?
    let type: String?
    let muscle: String?
    let difficulty: String?
    
    func toQueryItems() -> [URLQueryItem] {
        var items = [URLQueryItem]()
        
        if let name = name {
            items.append(URLQueryItem(name: "name", value: name))
        }
        if let type = type {
            items.append(URLQueryItem(name: "type", value: type))
        }
        if let muscle = muscle {
            items.append(URLQueryItem(name: "muscle", value: muscle))
        }
        if let difficulty = difficulty {
            items.append(URLQueryItem(name: "difficulty", value: difficulty))
        }
        
        return items
    }
}
