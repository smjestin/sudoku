## Synopsis

Assignment 2, in which an iOS app for a SUDOKU game, written in Swift. It is optimized for iPhone 6 and up, and uses SQLite to support two tables, Gameboard and Scores. SQLite is added to app for read/write using SQLiteDB, which is a Swift wrapper that incorporates the functionality and allows SELECT, INSERT, DELETE statements. It can be located here:

	https://github.com/FahimF/SQLiteDB

The Gameboard table contains a repository of over 1465 games, which were taken from the small text database of Sudoku puzzle provided on Moodle, sudoku.db, and converted into an SQLite database. 

## Gameplay
This version of Sudoku is played by hitting “start,” which will generate a puzzle. Users can then input any value 1-9 in any of the available boxes, and are able to edit these boxes again at any time. They are timed for the duration of the game, and are notified for incorrect moves and once the game has been completed. At any time, users can click the “reset” button, which will remove all changes to the puzzle, or, after a reset, click the “new” button to start a fresh game.

When a game is won, the user can see if they have reached a new best time, as well as see the top three best times overall. 

## Functionality

### Minimum Functionality
* User can start game
* User can reset game
* User can start new game
* User can play one game
* 9x9 grid is created, and user can fill elements with valid values
* Game notifies user for incorrect move
* Game notifies user on win

### Bonus Functionality
* Timer functionality has been implemented
 * Timer stops on reset
 * Timer is added to database when game is won
 * Timer information can be pulled from database to determine best times
 * User can see their high scores on win
* User can play up to 1500 different games
* Game makes auditory notification when a row, column, or box is complete
* Game makes auditory notification when the game has been won
* Game has an icon for iPhones

## Known Bugs
Currently, there are few known bugs, but those that exist are:

* Occasionally, editable boxes will have the same font as non-editable boxes, and therefore any input value looks to be a hardcoded piece of the puzzle
* AlertViews were implemented instead of AlertControllers, because UITextField actions would be pushed twice in the event a game was completed and an AlertController was presented. This was assumed to be because the UITextField element is not resigned as first responder when opening a new view, but ultimately this meant that scores were being input twice, and the resulting high scores were skewed

## Future Development
* New view to see high scores at any given time, not just once the game is won
* Implementation of solutions to the puzzles
* Optimize for iPhone 5S, iPad
* Allow users to “pencil” in some answers if they don’t want to fully commit



