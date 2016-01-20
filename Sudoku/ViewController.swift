//
//  ViewController.swift
//  Sudoku
//
//  Created by Shelby Jestin on 2016-01-15.
//  Copyright © 2016 Shelby Jestin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var sudokuView: UIView!
    @IBOutlet weak var timer: UILabel!
    var grid = [UITextField()]
    var height: CGFloat = 0.0
    var width: CGFloat = 0.0
    var startTime = NSTimeInterval()
    var time = NSTimer()
    
    //var gameBoard: [String] = ["4", "", "", "", "3", "", "", "", "", "", "", "", "6", "", "", "8", "", "", "", "", "", "", "", "", "", "", "1", "", "", "", "", "5", "", "", "9", "", "", "8", "", "", "", "", "6", "", "", "", "7", "", "2", "", "", "", "", "", "", "", "", "1", "", "2", "7", "", "", "5", "", "3", "", "", "", "", "4", "", "9", "", "", "", "", "", "", "", ""]
    
    var gameBoard: [String] = ["5", "3", "", "", "7", "", "", "", "", "6", "", "", "1", "9", "5", "", "", "", "", "9", "8", "", "", "", "", "6", "", "8", "", "", "", "6", "", "", "", "3", "4", "", "", "8", "", "3", "", "", "1", "7", "", "", "", "2", "", "", "", "6", "", "6", "", "", "", "", "2", "8", "", "", "", "", "4", "1", "9", "", "", "5", "", "", "", "", "8", "", "", "7", "9"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        width = CGFloat((Double(screenSize.width) / 9) - 10)
        height = CGFloat((Double(screenSize.height) / 9) - 10)
        for var y = 0; y < 9; y++ {
            for var x = 0; x < 9; x++ {
                var horizontal = CGFloat(Double(screenSize.width - 20) * 0.11 * Double(x))
                var vertical = CGFloat(Double(screenSize.width - 20) * 0.11 * Double(y))
                if x == 1 || x == 2 || x == 4 || x == 5 || x == 7 || x == 8  {
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
    
    @IBAction func startGame(sender: AnyObject) {
        if sender.currentTitle!! == "Start" {
            for var i = 0; i < 81; i++ {
                grid[i + 1].text = gameBoard[i]
                if(gameBoard[i] != "") {
                    grid[i + 1].font = UIFont(name: "HelveticaNeue-Bold", size: min(height, width))
                    grid[i + 1].enabled = false
                }
                else {
                    grid[i + 1].enabled = true
                }
            }
            sender.setTitle("Reset", forState: .Normal)
            if !time.valid {
                let aSelector : Selector = "updateTime"
                time = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector,     userInfo: nil, repeats: true)
                startTime = NSDate.timeIntervalSinceReferenceDate()
            }
        }
        else if sender.currentTitle!! == "Reset" {
            sender.setTitle("Start", forState: .Normal)
            
            for var i = 1; i < 81; i++ {
                if grid[i].enabled {
                    grid[i].text = ""
                }
            }
        }
    }
    
    func gameMove(sender: UITextField!) {
        let index = grid.indexOf(sender)
        let column = index! % 9
        var row = 0
        if(column != 0) {
            row = Int(index! / 9) + 1
        }
        else {
            row = Int(index! / 9)
        }
        var good = true
        var done = true
        
        //check row for values
        for var i = (row - 1) * 9 + 1; i <= (row - 1) * 9 + 8; i++ {
            if grid[i].text! == sender.text && i != index! && sender.text != "" {
                print(grid[i].text! + ", " + String(row) + ", " + String(i) + ", " + String(Int((i / 10) + 1)))
                good = false
            }
        }
        
        //check column for values
        for var i = column; i < 81; i += 9 {
            if grid[i].text! == sender.text && i != index! && sender.text != "" {
                print(grid[i].text! + ", " +  String(i) + ", " + String(Int(i % 9)))
                good = false
            }
        }
        
        //check box for values
        
        
        for var i = 1; i < 81; i++ {
            if grid[i].text! == "" {
                done = false
                i = 81
            }
        }
        if !good {
            sender.text = ""
            let alertView = UIAlertView()
            alertView.addButtonWithTitle("Okay")
            alertView.title = "Invalid Move"
            alertView.message = "That value cannot be placed here."
            alertView.show()
            
        }
        
        if done {
            let alertView = UIAlertView()
            alertView.addButtonWithTitle("Okay")
            alertView.title = "YAYYYYYYY"
            alertView.message = "Boom. Nailed it."
            alertView.show()
            time.invalidate()
        }
    }

    func updateTime() {
        
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
    
    func resetTime() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}