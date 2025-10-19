//
//  ChatGPT5_2048Tests.swift
//  ChatGPT5_2048Tests
//
//  Created by Tatiana Kornilova on 07/10/2025.
//

import XCTest

@testable import ChatGPT5_2048

final class ChatGPT5_2048Tests: XCTestCase {
    var game : Game!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        game = Game()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSlideLeft () {
        game.tiles = [
                Tile(value: 2, position: Position(row: 0, col: 0)),
                Tile(value: 4, position: Position(row: 0, col: 2)),
                Tile(value: 2, position: Position(row: 1, col: 2)),
                Tile(value: 2, position: Position(row: 2, col: 1)),
                Tile(value: 4, position: Position(row: 2, col: 3)),
                Tile(value: 4, position: Position(row: 3, col: 0)),
                Tile(value: 4, position: Position(row: 3, col: 1)),
                Tile(value: 2, position: Position(row: 3, col: 3))
            ]
            
        let moved = game.slide(direction: .left)
            
            XCTAssertTrue(moved)
            XCTAssertEqual(game.score, 8)
            XCTAssertEqual(game.tiles.count, 7)
        
            print (game.tiles.map {$0.value})
            print (game.tiles.map {$0.position})
        
        XCTAssertEqual(game.tiles[0].value, 2)
        XCTAssertEqual(game.tiles[0].position, Position(row: 0, col: 0))
        XCTAssertEqual(game.tiles[1].value, 4)
        XCTAssertEqual(game.tiles[1].position, Position(row: 0, col: 1))
        XCTAssertEqual(game.tiles[2].value, 2)
        XCTAssertEqual(game.tiles[2].position, Position(row: 1, col: 0))
        XCTAssertEqual(game.tiles[3].value, 2)
        XCTAssertEqual(game.tiles[3].position, Position(row: 2, col: 0))
        XCTAssertEqual(game.tiles[4].value, 4)
        XCTAssertEqual(game.tiles[4].position, Position(row: 2, col: 1))
        XCTAssertEqual(game.tiles[5].value, 8)
        XCTAssertEqual(game.tiles[5].position, Position(row: 3, col: 0))
        XCTAssertEqual(game.tiles[6].value, 2)
        XCTAssertEqual(game.tiles[6].position, Position(row: 3, col: 1))

        }
    
    func testSlideLeft1 () {
        game.tiles = [
            Tile(value: 2, position: Position(row: 0, col: 0)),
            Tile(value: 2, position: Position(row: 0, col: 1)),
            Tile(value: 4, position: Position(row: 0, col: 3)),
            Tile(value: 4, position: Position(row: 1, col: 0)),
            Tile(value: 4, position: Position(row: 1, col: 1)),
            Tile(value: 2, position: Position(row: 1, col: 2)),
            Tile(value: 2, position: Position(row: 1, col: 3)),
            Tile(value: 2, position: Position(row: 2, col: 0)),
            Tile(value: 2, position: Position(row: 2, col: 1)),
            Tile(value: 4, position: Position(row: 2, col: 2)),
            Tile(value: 4, position: Position(row: 2, col: 3)),
            Tile(value: 4, position: Position(row: 3, col: 0)),
            Tile(value: 4, position: Position(row: 3, col: 2))
            ]
            
        let moved = game.slide(direction: .left)
            
            XCTAssertTrue(moved)
            XCTAssertEqual(game.score, 36)
            XCTAssertEqual(game.tiles.count, 7)
        
            print (game.tiles.map {$0.value})
            print (game.tiles.map {$0.position})
        
        XCTAssertEqual(game.tiles[0].value, 4)
        XCTAssertEqual(game.tiles[0].position, Position(row: 0, col: 0))
        XCTAssertEqual(game.tiles[1].value, 4)
        XCTAssertEqual(game.tiles[1].position, Position(row: 0, col: 1))
        XCTAssertEqual(game.tiles[2].value, 8)
        XCTAssertEqual(game.tiles[2].position, Position(row: 1, col: 0))
        XCTAssertEqual(game.tiles[3].value, 4)
        XCTAssertEqual(game.tiles[3].position, Position(row: 1, col: 1))
        XCTAssertEqual(game.tiles[4].value, 4)
        XCTAssertEqual(game.tiles[4].position, Position(row: 2, col: 0))
        XCTAssertEqual(game.tiles[5].value, 8)
        XCTAssertEqual(game.tiles[5].position, Position(row: 2, col: 1))
        XCTAssertEqual(game.tiles[6].value, 8)
        XCTAssertEqual(game.tiles[6].position, Position(row: 3, col: 0))

        }
    
    
    func testSlideRight () {
        game.tiles = [
                Tile(value: 2, position: Position(row: 0, col: 0)),
                Tile(value: 2, position: Position(row: 0, col: 1)),
                Tile(value: 4, position: Position(row: 0, col: 2)),
                Tile(value: 4, position: Position(row: 0, col: 3)),
                Tile(value: 2, position: Position(row: 1, col: 1)),
                Tile(value: 2, position: Position(row: 1, col: 3)),
                Tile(value: 4, position: Position(row: 2, col: 0)),
                Tile(value: 4, position: Position(row: 2, col: 1)),
                Tile(value: 4, position: Position(row: 2, col: 2)),
                Tile(value: 4, position: Position(row: 2, col: 3)),
                Tile(value: 2, position: Position(row: 3, col: 3))
            ]
            
        let moved = game.slide(direction: .right)
            
            XCTAssertTrue(moved)
            XCTAssertEqual(game.score, 32)
            XCTAssertEqual(game.tiles.count, 6)
        
            print (game.tiles.map {$0.value})
            print (game.tiles.map {$0.position})
           
            XCTAssertEqual(game.tiles[0].value, 8)
            XCTAssertEqual(game.tiles[0].position, Position(row: 0, col: 3))
            XCTAssertEqual(game.tiles[1].value, 4)
            XCTAssertEqual(game.tiles[1].position, Position(row: 0, col: 2))
            XCTAssertEqual(game.tiles[2].value, 4)
            XCTAssertEqual(game.tiles[2].position, Position(row: 1, col: 3))
            XCTAssertEqual(game.tiles[3].value, 8)
            XCTAssertEqual(game.tiles[3].position, Position(row: 2, col: 3))
            XCTAssertEqual(game.tiles[4].value, 8)
            XCTAssertEqual(game.tiles[4].position, Position(row: 2, col: 2))
            XCTAssertEqual(game.tiles[5].value, 2)
            XCTAssertEqual(game.tiles[5].position, Position(row: 3, col: 3))
            
        }
    
    func testSlideUp() {
        game.tiles = [
            Tile(value: 2, position: Position(row: 0, col: 0)),
            Tile(value: 2, position: Position(row: 0, col: 1)),
            Tile(value: 4, position: Position(row: 0, col: 3)),
            Tile(value: 4, position: Position(row: 1, col: 0)),
            Tile(value: 4, position: Position(row: 1, col: 1)),
            Tile(value: 2, position: Position(row: 1, col: 2)),
            Tile(value: 2, position: Position(row: 1, col: 3)),
            Tile(value: 2, position: Position(row: 2, col: 0)),
            Tile(value: 2, position: Position(row: 2, col: 1)),
            Tile(value: 4, position: Position(row: 2, col: 2)),
            Tile(value: 4, position: Position(row: 2, col: 3)),
            Tile(value: 4, position: Position(row: 3, col: 0)),
            Tile(value: 4, position: Position(row: 3, col: 2))
        ]
        
        let moved = game.slide(direction: .up)
        
        XCTAssertTrue(moved)
        XCTAssertEqual(game.score, 8)
        XCTAssertEqual(game.tiles.count, 12)
       
        print (game.tiles.map {$0.value})
        print (game.tiles.map {$0.position})
       
        XCTAssertEqual(game.tiles[0].value, 2)
        XCTAssertEqual(game.tiles[0].position, Position(row: 0, col: 0))
        XCTAssertEqual(game.tiles[1].value, 4)
        XCTAssertEqual(game.tiles[1].position, Position(row: 1, col: 0))
        XCTAssertEqual(game.tiles[2].value, 2)
        XCTAssertEqual(game.tiles[2].position, Position(row: 2, col: 0))
        XCTAssertEqual(game.tiles[3].value, 4)
        XCTAssertEqual(game.tiles[3].position, Position(row: 3, col: 0))
        XCTAssertEqual(game.tiles[4].value, 2)
        XCTAssertEqual(game.tiles[4].position, Position(row: 0, col: 1))
        XCTAssertEqual(game.tiles[5].value, 4)
        XCTAssertEqual(game.tiles[5].position, Position(row: 1, col: 1))
        XCTAssertEqual(game.tiles[6].value, 2)
        XCTAssertEqual(game.tiles[6].position, Position(row: 2, col: 1))
        XCTAssertEqual(game.tiles[7].value, 2)
        XCTAssertEqual(game.tiles[7].position, Position(row: 0, col: 2))
        XCTAssertEqual(game.tiles[8].value, 8)
        XCTAssertEqual(game.tiles[8].position, Position(row: 1, col: 2))
        XCTAssertEqual(game.tiles[9].value, 4)
        XCTAssertEqual(game.tiles[9].position, Position(row: 0, col: 3))
        XCTAssertEqual(game.tiles[10].value, 2)
        XCTAssertEqual(game.tiles[10].position, Position(row: 1, col: 3))
        XCTAssertEqual(game.tiles[11].value, 4)
        XCTAssertEqual(game.tiles[11].position, Position(row: 2, col: 3))
        
    }
    
    func testSlideDown () {
        game.tiles = [
            Tile(value: 2, position: Position(row: 0, col: 0)),
            Tile(value: 2, position: Position(row: 0, col: 1)),
            Tile(value: 4, position: Position(row: 0, col: 3)),
            Tile(value: 4, position: Position(row: 1, col: 0)),
            Tile(value: 4, position: Position(row: 1, col: 1)),
            Tile(value: 2, position: Position(row: 1, col: 2)),
            Tile(value: 2, position: Position(row: 1, col: 3)),
            Tile(value: 2, position: Position(row: 2, col: 0)),
            Tile(value: 2, position: Position(row: 2, col: 1)),
            Tile(value: 4, position: Position(row: 2, col: 2)),
            Tile(value: 4, position: Position(row: 2, col: 3)),
            Tile(value: 4, position: Position(row: 3, col: 0)),
            Tile(value: 4, position: Position(row: 3, col: 2))
        ]
        
        let moved = game.slide(direction: .down)
        
        XCTAssertTrue(moved)
        XCTAssertEqual(game.score, 8)
        XCTAssertEqual(game.tiles.count, 12)
       
        print (game.tiles.map {$0.value})
        print (game.tiles.map {$0.position})
       
        XCTAssertEqual(game.tiles[0].value, 4)
        XCTAssertEqual(game.tiles[0].position, Position(row: 3, col: 0))
        XCTAssertEqual(game.tiles[1].value, 2)
        XCTAssertEqual(game.tiles[1].position, Position(row: 2, col: 0))
        XCTAssertEqual(game.tiles[2].value, 4)
        XCTAssertEqual(game.tiles[2].position, Position(row: 1, col: 0))
        XCTAssertEqual(game.tiles[3].value, 2)
        XCTAssertEqual(game.tiles[3].position, Position(row: 0, col: 0))
        XCTAssertEqual(game.tiles[4].value, 2)
        XCTAssertEqual(game.tiles[4].position, Position(row: 3, col: 1))
        XCTAssertEqual(game.tiles[5].value, 4)
        XCTAssertEqual(game.tiles[5].position, Position(row: 2, col: 1))
        XCTAssertEqual(game.tiles[6].value, 2)
        XCTAssertEqual(game.tiles[6].position, Position(row: 1, col: 1))
        XCTAssertEqual(game.tiles[7].value, 8)
        XCTAssertEqual(game.tiles[7].position, Position(row: 3, col: 2))
        XCTAssertEqual(game.tiles[8].value, 2)
        XCTAssertEqual(game.tiles[8].position, Position(row: 2, col: 2))
        XCTAssertEqual(game.tiles[9].value, 4)
        XCTAssertEqual(game.tiles[9].position, Position(row: 3, col: 3))
        XCTAssertEqual(game.tiles[10].value, 2)
        XCTAssertEqual(game.tiles[10].position, Position(row: 2, col: 3))
        XCTAssertEqual(game.tiles[11].value, 4)
        XCTAssertEqual(game.tiles[11].position, Position(row: 1, col: 3))
    }
    
    func testSlideLeftDifferentResults() {
        game.tiles = [
            Tile(value: 4, position: Position(row: 0, col: 0))
            ]
            
        let moved = game.slide(direction: .left)
            
            XCTAssertTrue(!moved)
            XCTAssertEqual(game.score, 0)
            XCTAssertEqual(game.tiles.count, 1)
        
            print (game.tiles.map {$0.value})
            print (game.tiles.map {$0.position})
    }
    
    func testSlideLeftMissedMerge() {
        game.tiles = [
            Tile(value: 4, position: Position(row: 0, col: 0)),
            Tile(value: 4, position: Position(row: 0, col: 1)),
            Tile(value: 4, position: Position(row: 0, col: 2)),
            Tile(value: 4, position: Position(row: 0, col: 3))
            ]
            
        let moved = game.slide(direction: .left)
            
            XCTAssertTrue(moved)
            XCTAssertEqual(game.score, 16)
            XCTAssertEqual(game.tiles.count, 2)
        
            print (game.tiles.map {$0.value})
            print (game.tiles.map {$0.position})
        
        XCTAssertEqual(game.tiles[0].value, 8)
        XCTAssertEqual(game.tiles[0].position, Position(row: 0, col: 0))
        XCTAssertEqual(game.tiles[1].value, 8)
        XCTAssertEqual(game.tiles[1].position, Position(row: 0, col: 1))
    }

}
