//
//  GameBoard. swift
//  Sudoku
//
//  Created by Shelby Jestin on 2016-01-16.
//  Copyright © 2016 Shelby Jestin. All rights reserved.
//

import Foundation

class GameBoard {
    var board : [String]
    
    init() {
        board = []
    }
    
    init(random: Int) {
        
        let db = SQLiteDB.sharedInstance()
        var result = db.query("select * from gameboard where id=?", parameters: [random])
        
        board = String(result[0]["gameboard"]!).characters.split {$0 == ","}.map(String.init)
    }
    
    func getBoard() -> [String] {
        return board
    }
    
    func setBoard(random: Int) {
        let db = SQLiteDB.sharedInstance()
        var result = db.query("select * from gameboard where id=?", parameters: [random])
        
        board = String(result[0]["gameboard"]!).characters.split {$0 == ","}.map(String.init)
    }
}