//
//  RandomNameGenerator.swift
//  BlocFit
//
//  Created by Colin Conduff on 10/6/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import Foundation

struct RandomNameGenerator {
    static let adjectives = [
        "Red", "Green", "Blue", "Yellow", "Brown", "Orange", "Grey"
    ]
    static let nouns = [
        "Lake", "Pond", "River", "Bear", "Cat", "Dog", "Sun", "Sky",
        "Horse", "Deer", "Crow", "Tiger", "Lion", "Squirrel", "Rabbit",
        "Frog", "Reindeer", "Eagle", "Walrus", "Koala", "Turtle"
    ]
    static func getRandomName() -> String {
        let randomAdjectiveIndex = Int(arc4random_uniform(UInt32(adjectives.count)))
        let randomNounIndex = Int(arc4random_uniform(UInt32(nouns.count)))
        let randomAdjective = adjectives[randomAdjectiveIndex]
        let randomNoun = nouns[randomNounIndex]
        let randomNumber = String(Int(arc4random_uniform(100)))
        return randomAdjective + randomNoun + randomNumber
    }
}
