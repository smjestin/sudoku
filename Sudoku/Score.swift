//
//  Score.swift
//  Sudoku
//
//  Created by Shelby Jestin on 2016-02-01.
//  Copyright © 2016 Shelby Jestin. All rights reserved.
//

import Foundation

class Score {
    
    let db = SQLiteDB.sharedInstance()
    
    func insertScore(time: String) {
        db.execute("insert into scores (time) values (?)", parameters: [time])
    }
    
    func getHighScores() -> String {
        let highScores = db.query("select time from scores order by time limit 3")
        return String(highScores[0]["time"]!) + "\n" + String(highScores[1]["time"]!) + "\n" + String(highScores[2]["time"]!)
    }
    
}