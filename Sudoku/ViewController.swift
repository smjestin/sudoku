//
//  ViewController.swift
//  Sudoku
//
//  Created by Shelby Jestin on 2016-01-15.
//  Copyright © 2016 Shelby Jestin. All rights reserved.
//
//  This class is used to implement the main Game functionality,
//  and contains a number of different functions that manipulate
//  the content of the view.

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    /* UI ELEMENTS */
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var sudokuView: UIView!
    @IBOutlet weak var timer: UILabel!
    var grid = [UITextField()]
    
    /* AUDIO ELEMENTS */
    var audioPlayer:AVAudioPlayer!
    var winnerURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("winnerSound", ofType: "mp3")!)
    var applauseURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("applauseSound", ofType: "mp3")!)
    
    /* GAMEBOARD ELEMENTS */
    var height: CGFloat = 0.0
    var width: CGFloat = 0.0
    var gameboard = GameBoard.init()
    var score = Score.init()
    
    /* ROW, COLUMN, BOX TRACKERS*/
    var completeRows = [Bool](count: 9, repeatedValue: false)
    var completeColumns = [Bool](count: 9, repeatedValue: false)
    
    /* TIMER ELEMENTS */
    var startTime = NSTimeInterval()
    var time = NSTimer()
    
    // SET UP GAMEBOARD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        width = CGFloat((Double(screenSize.width) / 9) - 10)
        height = CGFloat((Double(screenSize.height) / 9) - 10)

        for var y = 0; y < 9; y++ {                     // create 9x9 grid
            for var x = 0; x < 9; x++ {
                //calculate horizontal placement of element
                var horizontal = CGFloat(Double(screenSize.width - 20) * 0.11 * Double(x))
                //calculate vertical placement of element
                var vertical = CGFloat(Double(screenSize.width - 20) * 0.11 * Double(y))
                if x == 1 || x == 2 || x == 4 || x == 5 || x == 7 || x == 8  {      // align in 9x9 squares horizontally
                    horizontal = horizontal - 4
                    if x == 2 || x == 5 || x == 8 {
                        horizontal = horizontal - 4
                    }
                }
                if y == 1 || y == 2 || y == 4 || y == 5 || y == 7 || y == 8 {       // align in 9x9 squares vertically
                    vertical = vertical - 4
                    if y == 2 || y == 5 || y == 8 {
                        vertical = vertical - 4
                    }
                }
                // create frame to hold element
                let frame = CGRect(x: horizontal, y: vertical, width: min(height, width), height: min(height, width))
                // create text field within frame
                let coordinate: UITextField = UITextField(frame: frame)
                coordinate.text = ""    // empty
                coordinate.backgroundColor = UIColor(red: (243/255.0), green: (243/255.0), blue: (243/255.0), alpha: 1.0)
                coordinate.textColor = UIColor(red: (13/255.0), green: (77/255.0), blue: (77/255.0), alpha: 1.0)
                coordinate.textAlignment = .Center
                coordinate.font = UIFont(name: "HelveticaNeue-UltraLight", size: min(height, width))
                coordinate.adjustsFontSizeToFitWidth = true
                coordinate.addTarget(self, action: "gameMove:", forControlEvents: .EditingDidEnd) //add action to gameMove()
                coordinate.keyboardType = UIKeyboardType.NumberPad  // ensure that the numberpad is the only keyboard
                coordinate.enabled = false                          // user cannot edit by default
                sudokuView.addSubview(coordinate)                   // add to sudokuView
                grid.append(coordinate)                             // add to grid
            }
        }
    }
    
    // WHEN START BUTTON IS CLICKED
    @IBAction func startGame(sender: UIButton!) {
        resetTimer()    // start timer over
        if sender.currentTitle! == "Start" || sender.currentTitle! == "New"{       // if user hasn't started game
            let random = Int(arc4random_uniform(1465) + 1)                           // randomly select game
            gameboard.setBoard(random)
            let board = gameboard.getBoard()
            for var i = 0; i < 81; i++ {            //set gameboard
                if(board[i] != "nil") {
                    grid[i + 1].text = board[i]
                    grid[i + 1].font = UIFont(name: "HelveticaNeue-Bold", size: min(height, width))
                    grid[i + 1].enabled = false     //disabled gameboard values
                }
                else {
                    grid[i+1].text = ""
                    grid[i + 1].enabled = true      // rest of values are enabled
                }
            }
            sender.setTitle("Reset", forState: .Normal)
        }
        else if sender.currentTitle! == "Reset" {  //if reset, reset the board
            sender.setTitle("New", forState: .Normal)
            for var i = 1; i < 81; i++ {
                if grid[i].enabled {
                    grid[i].text = ""
                }
            }
        }
    }
    
    // WHEN USER INPUTS VALUE IN ELEMENT
    @IBAction func gameMove(sender: UITextField!) {
        let index = grid.indexOf(sender)
        let column = index! % 9             //calculate row of input
        var row = 0
        if(column != 0) { row = Int(index! / 9) + 1  }           //calculate column of input
        else { row = Int(index! / 9) }
        
        var valid = true
        // verify the validity of the input
        valid = validateBox(row, column: column, index: index!, value: sender.text!) && validateRow(row, index: index!, value: sender.text!) && validateColumn(column, index: index!, value: sender.text!)
        if !valid {                          //prevent user if input is invalid
            alert("Invalid Move", message: "That value cannot be placed here.")
            sender.text = ""
        }
        
        if validateDone() {                           // alert user if game is done
            time.invalidate()                         // stop timer
            playSound("applause")                     // play something if the game is done
            score.insertScore(timer.text!)            // add score to Score
            let highScores = score.getHighScores()    // get all highScores
            var message = "You successfully completed this puzzle." // create alert message
            if score.newHighScore(timer.text!) {
                message = message + "\n\nNew high score! Your time: " + timer.text!
            }
            else {
                message = message + "\n\nYour score: \n" + timer.text!
            }
            message = message + "\n\nHigh scores: \n" + String(highScores)
            alert("Congratulations", message: message)
            startButton.setTitle("New", forState: .Normal)   // allow user to start new game, instead of reset
        }
        
        if !validateValue(sender.text!) {             // ensure that the input is valid
            alert("Invalid Value", message: "Input value must be a number from 1-9.")
            sender.text = ""
        }
    }
    
    // VALIDATE THAT THE NUMBER CAN BE PLACED IN BOX
    func validateBox(row: Int, column: Int, index: Int, value: String) -> Bool {
        var startPoint = 0
        var valid = true;
        
        // conditional statements determine the starting point of the box, to begin counting
        if column == 1 || column == 4 || column == 7 {  // 1, 4, 7 are the leftmost values for columns
            startPoint = index
        }
        else if column == 2 || column == 5 || column == 8 { // 2, 5, 8 are in the middle
            startPoint = index - 1
        }
        else if column == 3 || column == 6 || column == 0 { // 3, 6, 9 are the rightmost
            startPoint = index - 2
        }
        
        // 1, 4, 7 for row don't have to be checked, because the startPoint will
        // therefore already be in the appropriate location
        if row == 2 || row == 5 || row == 8 {   // 2, 5, 8 are again the middle for rows
            startPoint = startPoint - 9
        }
        else if row == 3 || row == 6 || row == 9 {  // 3, 6, 9 are rightmost
            startPoint = startPoint - 18
        }
        
        var jumpCounter = 0;
        var counter = 0;
        for var i = startPoint; i <= startPoint + 21; i++ { // run until end of box
            jumpCounter++;
            if grid[i].text! == value && i != index && value != "" {    // validate entry
                valid = false
            }
            
            if grid[i].text! != "" {
                counter = counter + Int(grid[i].text!)!     // count sum of row
            }
            
            if jumpCounter == 3 {   // jump to next line of box
                i = i + 6
                jumpCounter = 0
            }
        }
        if counter == 45 {  // if sum = 45, box is complete
            playSound("winner") // alert user that they've completed a box
        }
        return valid
    }
    
    // VALIDATE THAT THE NUMBER CAN BE PLACED IN ROW
    func validateRow(row: Int, index: Int, value: String) -> Bool {
        var counter = 0
        for var i = (row - 1) * 9 + 1; i <= (row - 1) * 9 + 9; i++ {    // run until end of row
            if grid[i].text! == value && i != index && value != "" {    // return if another value is the same
                return false
            }
            if grid[i].text! != "" {
                counter = counter + Int(grid[i].text!)!     // count sum of row
            }
        }
        if counter == 45 {  // if sum = 45, row is complete
            playSound("winner") // alert user that they've completed a row
            completeRows[row % 9] = true    // change array to reflect this row is complete
        }
        return true
    }
    
    // VALIDATE THAT THE NUMBER CAN BE PLACED IN COLUMN
    func validateColumn(column: Int, index: Int, value: String) -> Bool {
        var counter = 0
        for var i = column; i < 82; i += 9 {    // run until end of column
            if grid[i].text! == value && i != index && value != "" {    // return if another value is the same
                return false
            }
            if grid[i].text! != "" {    // count sum of column
                counter = counter + Int(grid[i].text!)!
            }
        }
        if counter == 45 {  // if sum = 45, column is complete
            playSound("winner") // alert user of completed column
            completeColumns[column] = true  // change array to reflect this column is complete
        }
        return true
    }
    
    // VALIDATE THAT THE INPUT IS CORRECT
    func validateValue(value: String) -> Bool {
        if value != "" && value != "1" && value != "2" && value != "3" && value != "4" && value != "5" && value != "6" && value != "7" && value != "8" && value != "9" {    // check that the value is a number, 1-9
            return false
        }
        return true
    }
    
    // VALIDATE THAT THE GAME IS DONE
    func validateDone() -> Bool {
        for var i = 0; i < 9; i++ {     // check that rows are complete (row = 45)
            if completeRows[i] == false {
                return false            // otherwise, return
            }
        }
        for var i = 0; i < 9; i++ {     // check that columns are complete (columns = 45)
            if completeColumns[i] == false {
                return false            // otherwise, return
            }
        }
        for var i = 1; i < 82; i++ {    // check that all boxes have been filled
            if grid[i].text! == "" {
                return false            // otherwise, return
            }
        }
        return true
    }
    
    // CREATE AN ELERT FOR A SPECIFIC EVENT
    func alert(title: String, message: String) {
        let alertView = UIAlertView()
        alertView.addButtonWithTitle("OK")
        alertView.title = title
        alertView.message = message
        alertView.show()
    }
    
    // UPDATE TIMER EVERY SECOND
    func updateTimer() {
        
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        var elapsedTime: NSTimeInterval = currentTime - startTime
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        
        let seconds = UInt8(elapsedTime)
        
        elapsedTime -= NSTimeInterval(seconds)
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
         
        timer.text = "\(strMinutes):\(strSeconds)"
        
    }
    
    // START TIMER FROM ZERO
    func startTimer() {
        if !time.valid {                        //start timer
            let aSelector : Selector = "updateTimer"
            time = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector,     userInfo: nil, repeats: true)
            startTime = NSDate.timeIntervalSinceReferenceDate()
        }
    }
    
    // RESET TIMER TO ZERO
    func resetTimer() {
        time.invalidate()
        startTimer()
    }
    
    // PLAY SOUND WHEN CALLED
    func playSound(type: String) {
        var error:NSError? = nil
        do {
            if type == "applause" { // if game is won
                try audioPlayer = AVAudioPlayer(contentsOfURL: applauseURL) }
            else {                  // if row/column is done
                try audioPlayer = AVAudioPlayer(contentsOfURL: winnerURL) }
            audioPlayer.play()
        } catch {
            print(error)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}