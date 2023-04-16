//
//  WeatherModel.swift
//  RyfWeather
//
//  Created by renyafang on 2023/4/16.
//

import UIKit


class WeatherModel: NSObject {
    var adcode: String?
    var city: String?
    var humidity: Int?
    var humidity_float: Float?
    var province: String?
    var reporttime: String?
    var temperature: String?
    var temperature_float: Float?
    var weather: String?
    var winddirection: String?
    var windpower: String?
    
    class func dictToModel(list:[String:AnyObject])->WeatherModel{
        var model = WeatherModel(dict: list)
        return model
    }
    
    init(dict:[String:AnyObject]){
        super.init()
        self.adcode = dict["adcode"] as! String
        self.city = dict["city"] as! String
        self.temperature = dict["temperature"] as! String
        self.weather = dict["weather"] as! String
    }
    
}
