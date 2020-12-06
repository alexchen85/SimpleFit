//
//  WeightData.swift
//  SimpleFit
//
//  Created by shuo on 2020/11/28.
//

import Foundation

struct ChartData {
    
    var datas: [Any]?
    var clearDatas: [Any?]?
    var min: Double?
    var max: Double?
    var categories: [String]?
}

struct DailyData: Codable {
    
    var weight: Double?
    var photo: Photo?
    var note: String?
    var month: String = ""
    var day: String = ""
}

struct Photo: Codable {
    
    var url: String
    var isFavorite: Bool
}
