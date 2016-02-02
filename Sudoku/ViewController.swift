//
//  ViewController.swift
//  Sudoku
//
//  Created by Shelby Jestin on 2016-01-15.
//  Copyright © 2016 Shelby Jestin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    /* UI ELEMENTS */
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var sudokuView: UIView!
    @IBOutlet weak var timer: UILabel!
    var grid = [UITextField()]
    
    /* GAMEBOARD ELEMENTS */
    var height: CGFloat = 0.0
    var width: CGFloat = 0.0
    var gameboard = GameBoard.init()
    
    /* */
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
                var horizontal = CGFloat(Double(screenSize.width - 20) * 0.11 * Double(x))  //calculate height of squares
                var vertical = CGFloat(Double(screenSize.width - 20) * 0.11 * Double(y))    //calculate width of squares
                if x == 1 || x == 2 || x == 4 || x == 5 || x == 7 || x == 8  {              //align squares in sudoku grid
                    horizontal = horizontal - 4
                    if x == 2 || x == 5 || x == 8 {
                        horizontal = horizontal - 4
                    }
                }
                if y == 1 || y == 2 || y == 4 || y == 5 || y == 7 || y == 8 {
                    vertical = vertical - 4
                    if y == 2 || y == 5 || y == 8 {
                        vertical = vertical - 4
                    }
                }
                let frame = CGRect(x: horizontal, y: vertical, width: min(height, width), height: min(height, width))
                let coordinate: UITextField = UITextField(frame: frame)
                coordinate.text = ""
                coordinate.backgroundColor = UIColor(red: (243/255.0), green: (243/255.0), blue: (243/255.0), alpha: 1.0)
                coordinate.textColor = UIColor(red: (13/255.0), green: (77/255.0), blue: (77/255.0), alpha: 1.0)
                coordinate.textAlignment = .Center
                coordinate.font = UIFont(name: "HelveticaNeue-UltraLight", size: min(height, width))
                coordinate.adjustsFontSizeToFitWidth = true
                coordinate.addTarget(self, action: "gameMove:", forControlEvents: .EditingDidEnd)
                coordinate.keyboardType = UIKeyboardType.NumberPad
                coordinate.enabled = false
                sudokuView.addSubview(coordinate)
                grid.append(coordinate)
            }
        }
    }
    
    // WHEN START BUTTON IS CLICKED
    @IBAction func startGame(sender: AnyObject) {
        resetTimer()    // start timer over
        if sender.currentTitle!! == "Start" || sender.currentTitle!! == "New"{       // if user hasn't started game
            let random = Int(arc4random_uniform(1465) + 1)                          // randomly select game
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
        else if sender.currentTitle!! == "Reset" {  //if reset, reset the board
            sender.setTitle("New", forState: .Normal)
            for var i = 1; i < 81; i++ {
                if grid[i].enabled {
                    grid[i].text = ""
                }
            }
        }
    }
    
    // WHEN USER INPUTS VALUE
    func gameMove(sender: UITextField!) {
        let index = grid.indexOf(sender)
        gameboard.updateBoard(index!, value: sender.text!)
        
        let column = index! % 9             //calculate row of input
        var row = 0
        if(column != 0) { row = Int(index! / 9) + 1  }           //calculate column of input
        else { row = Int(index! / 9) }
        
        var valid = true
        var done = true
        
        valid = validateBox(row, column: column, index: index!, value: sender.text!) && validateRow(row, index: index!, value: sender.text!) && validateColumn(column, index: index!, value: sender.text!)
        
        // check if finished
        for var i = 1; i < 81; i++ {
            if grid[i].text! == "" {
                done = false
                i = 81
            }
        }
        
        if done {
            done = validateDone()
        }
        
        if !valid {                          //prevent user if input is invalid
            alert("Invalid Move", message: "That value cannot be placed here.")
            sender.text = ""
        }
        
        if done {                           //alert user if game is done
            alert("Congratulations", message: "You successfully completed this puzzle.")
            time.invalidate()
        }
        
        if !validateValue(sender.text!) {
            alert("Invalid Value", message: "Input value must be a number from 1-9.")
            sender.text = ""
        }
    }
    
    func validateBox(row: Int, column: Int, index: Int, value: String) -> Bool {
        var startPoint = 0
        var valid = true;
        
        if column == 1 || column == 4 || column == 7 {
            startPoint = index
        }
        else if column == 2 || column == 5 || column == 8 {
            startPoint = index - 1
        }
        else if column == 3 || column == 6 || column == 0 {
            startPoint = index - 2
        }
        
        if row == 2 || row == 5 || row == 8 {
            startPoint = startPoint - 9
        }
        else if row == 3 || row == 6 || row == 9 {
            startPoint = startPoint - 18
        }
        
        var counter = 0;
        for var i = startPoint; i <= startPoint + 21; i++ {
            counter++;
            if gameboard.getBoard()[i] == value && i != index && value != "" {
                print("Incorrect box: " + String(i) + " " + grid[i].text!)
                valid = false
            }
            
            if counter == 3 {
                i = i + 6
                counter = 0
            }
        }
        return valid
    }
    
    func validateRow(row: Int, index: Int, value: String) -> Bool {
        var valid = true
        var counter = 0
        for var i = (row - 1) * 9 + 1; i <= (row - 1) * 9 + 9; i++ {
            if grid[i].text! == value && i != index && value != "" {
                print("Incorrect row: " + String(i))
                valid = false
            }
            if grid[i].text! != "" {
                counter = counter + Int(grid[i].text!)!
            }
        }
        if counter == 45 {
            completeRows[row] = true
        }
        return valid
    }
    
    func validateColumn(column: Int, index: Int, value: String) -> Bool {
        var valid = true
        var counter = 0
        for var i = column; i < 81; i += 9 {
            if grid[i].text! == value && i != index && value != "" {
                print("Incorrect column: " + String(i))
                valid = false
            }
            if grid[i].text! != "" {
                counter = counter + Int(grid[i].text!)!
            }
        }
        if counter == 45 {
            completeColumns[column] = true
        }
        return valid
    }
    
    func validateValue(value: String) -> Bool {
        var valid = true
        if value != "" && value != "1" && value != "2" && value != "3" && value != "4" && value != "5" && value != "6" && value != "7" && value != "8" && value != "9" {
            valid = false
        }
        return valid
    }
    
    
    func validateDone() -> Bool {
        var valid = true
        for var i = 0; i < 9; i++ {
            if completeRows[i] == false {
                valid = false
                return valid
            }
        }
        for var i = 0; i < 9; i++ {
            if completeColumns[i] == false {
                valid = false
                return valid
            }
        }
        return valid
    }
        
    func alert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
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
    
    func startTimer() {
        if !time.valid {                        //start timer
            let aSelector : Selector = "updateTimer"
            time = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector,     userInfo: nil, repeats: true)
            startTime = NSDate.timeIntervalSinceReferenceDate()
        }
    }
    
    func stopTimer() {
        time.invalidate()
    }
    
    func resetTimer() {
        stopTimer()
        startTimer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}