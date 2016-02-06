//
//  Score.swift
//  Sudoku
//
//  Created by Shelby Jestin on 2016-02-01.
//  Copyright © 2016 Shelby Jestin. All rights reserved.
//
//  This class represents the scores of the user, and 
//  controls the "scores" table in gameboard.sqlite. It is
//  used to insert new scores, return highest scores, and 
//  to create functions that manipulate the elements in the 
//  Scores table directly.
//

import Foundation

class Score {
    
    let db = SQLiteDB.sharedInstance()
    
    // insert new score into database
    func insertScore(time: String) {
        db.execute("insert into scores (time) values (?)", parameters: [time])
    }
    
    // return three highest scores from this user
    func getHighScores() -> String {
        let highScores = db.query("select time from scores order by time limit 3") // get scores
        var returnString = ""
        for var i = 0; i < highScores.count; i++ {
            returnString = returnString + String(highScores[i]["time"]!) + "\n" // place scores in string
        }
        return returnString
    }
    
    // determine if new score is the highest
    func newHighScore(score: String) -> Bool {
        let highScores = String(getHighScores()).characters.split {$0 == "\n"}.map(String.init) // get high scores
        if highScores[1] == "" {    // return true if new score is the only one
            return true }
        else {                      // otherwise, compare to first highest score
            return score <= highScores[0] }
    }
}