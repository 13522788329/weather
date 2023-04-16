//
//  WeatherListController.swift
//  RyfWeather
//
//  Created by renyafang on 2023/4/16.
//

import UIKit
import AMapLocationKit
import AMapFoundationKit
import CoreXLSX

class WeatherListController: UIViewController, AMapLocationManagerDelegate, UIDocumentPickerDelegate {
    
    lazy var locationManager: AMapLocationManager = {
        let manager: AMapLocationManager = AMapLocationManager.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.locationTimeout = 2
        manager.reGeocodeTimeout = 2
        return manager
    }()
    
    var worksheetPathsAndNamesArray: [(name: String?, path: String?)]?
    var wbks: [Workbook]?
    
    let districts: [String] = ["Beijing", "Shanghai", "Guangzhou", "Shenzhen", "Suzhou", "Shengyang"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.orange
        self.navigationController?.isNavigationBarHidden = true
        loadXlsxFile()
    }
    
    func loadXlsxFile() {
        let path: String = Bundle.main.path(forResource: "AMap_citycode", ofType: "xlsx") ?? ""
        
        guard let file = XLSXFile(filepath: path) else {
            fatalError("\(path) content is not exist")
        }
        
        self.wbks = try!file.parseWorkbooks()
        guard (self.wbks?.count == 1) else {
            return
        }
        
        self.worksheetPathsAndNamesArray = try!file.parseWorksheetPathsAndNames(workbook: self.wbks![0])
        guard self.worksheetPathsAndNamesArray?.count == 1 else {
            return
        }
        
        for workItem in self.worksheetPathsAndNamesArray! {
            print("workItem is: \(workItem)")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

