//
//  GameBoard. swift
//  Sudoku
//
//  Created by Shelby Jestin on 2016-01-16.
//  Copyright © 2016 Shelby Jestin. All rights reserved.
//
//  This class represents the gameboards, and, unlike the
//  scores class, does not manipulation on the gameboards table.
//  Instead, it is used to select rows from the pre-filled table,
//  which exists as a separate file and can be added to at any time.
//  This class allows for the program to call an existing row, and 
//  manipulate that row without updating the actual table.
//


import Foundation

class GameBoard {
    var board : [String]
    
    // initiate empty gameboard
    init() {
        board = []
    }
    
    // initiate gameboard from random integer
    init(random: Int) {
        let db = SQLiteDB.sharedInstance()
        var result = db.query("select * from gameboard where id=?", parameters: [random])   // select random gameboard instance
        board = String(result[0]["gameboard"]!).characters.split {$0 == ","}.map(String.init) // get gameboard from selection
    }
    
    // return current board
    func getBoard() -> [String] {
        return board
    }
    
    // set current gameboard
    func setBoard(random: Int) {
        let db = SQLiteDB.sharedInstance()
        var result = db.query("select * from gameboard where id=?", parameters: [random])
        
        board = String(result[0]["gameboard"]!).characters.split {$0 == ","}.map(String.init)
    }
}