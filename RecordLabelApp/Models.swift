//
//  Model.swift
//  BandsApp
//
//  Created by Rui Alho on 14/10/20.
//

import Foundation

public struct MusicFestival: Codable {
    public let name: String?
    public let bands: [Band]
}

public struct Band: Codable {
    public let name: String
    public let recordLabel: String?
}

public struct RecordLabelViewModel: Equatable, Hashable {
    public static func == (lhs: RecordLabelViewModel, rhs: RecordLabelViewModel) -> Bool {
        return lhs.recordLabel == rhs.recordLabel
            && lhs.bandName == rhs.bandName
    }
    
    public let recordLabel: String
    public let bandName: String
    public let festivals: [String]
}

public struct BandsViewModel: Equatable, Hashable {
    public let name: String
    public let festival: String?
    public static func == (lhs: BandsViewModel, rhs: BandsViewModel) -> Bool {
        return lhs.name == rhs.name
            && lhs.festival == rhs.festival
    }
}


func mapViewModel(festivals:[MusicFestival]) -> Dictionary<String, [BandsViewModel]> {
    
    var bands = [BandsViewModel]()
    festivals.forEach { (festival) in
        for band in festival.bands {
            if let _ = band.recordLabel {
                bands.append(BandsViewModel(name: band.name, festival: festival.name))
            }
        }
    }
    bands.sort { (band1, band2) -> Bool in
        band1.festival ?? "" < band2.festival ?? ""
    }
    let groupedBands = Dictionary(grouping: bands, by: { $0.name })

    return groupedBands
}

extension Array where Element: Equatable {
    func uniqueElements() -> [Element] {
        var out = [Element]()
        
        for element in self {
            if !out.contains(element) {
                out.append(element)
            }
        }
        
        return out
    }
}
