//
//  JokeModel.swift
//  ChuckNorrisRandomJoke
//
//  Created by seungminOH on 2022/04/15.
//

import Foundation

struct JokeResponse: Decodable {
    let type: String
    let value: Joke
}

struct Joke: Decodable {
    let id: Int
    let joke: String
    let categories: [String]
}
