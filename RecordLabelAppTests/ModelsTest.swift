//
//  ModelsTest.swift
//  RecordLabelAppTests
//
//  Created by Rui Alho on 15/10/20.
//

import XCTest

class ModelsTest: XCTestCase {
    
    var festivals: [MusicFestival] = []
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let bundle = Bundle(for: type(of: self))
        let jsonDecoder = JSONDecoder()
        
        guard let url = bundle.url(forResource: "Data", withExtension: "json") else {
            XCTFail("Missing file: Data.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        festivals = try jsonDecoder.decode([MusicFestival].self, from: json)
    }
    
    func testJSONMapping() throws {
        XCTAssertEqual(festivals.count, 4)
        XCTAssertEqual(festivals[0].name, "Twisted Tour")
        XCTAssertEqual(festivals[0].bands.count, 5)
        XCTAssertEqual(festivals[0].bands[0].name, "Auditones")
        XCTAssertEqual(festivals[0].bands[0].recordLabel, "Marner Sis. Recording")
    }
    

    
}
