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
import Alamofire

class WeatherListController: UIViewController, AMapLocationManagerDelegate, UIDocumentPickerDelegate {
    
    lazy var locationManager: AMapLocationManager = {
        let manager: AMapLocationManager = AMapLocationManager.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.locationTimeout = 2
        manager.reGeocodeTimeout = 2
        return manager
    }()
    
    lazy var mainTable: UITableView = {
        let view: UITableView = UITableView.init(frame: CGRect(x: 0, y: 64.0, width: ScreenWidth, height: ScreenHeight - 64.0))
        view.register(WeatherItemCell.self, forCellReuseIdentifier: "WeatherItemCell")
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    var worksheetPathsAndNamesArray: [(name: String?, path: String?)]?
    var wbks: [Workbook]?
    var rowInfoArray: [RowInfoModel]?
    
    let districts: [String] = ["北京", "上海", "广州", "深圳", "苏州", "沈阳"]

    var dataArray: [WeatherModel]?
    var cityCodes: [String]?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        loadXlsxFile()
        self.view.addSubview(self.mainTable)
    }
    
    func loadXlsxFile() {
        self.dataArray = [WeatherModel]()
        self.cityCodes = [String]()
        
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
        
        let worksheetPathAndName: (name: String?, path: String?) = self.worksheetPathsAndNamesArray![0]
        if let worksheetName = worksheetPathAndName.name {
            print("This worksheet has a name: \(worksheetName)")
        }
        let worksheet = try!file.parseWorksheet(at: worksheetPathAndName.path ?? "")
        
        guard let rows = worksheet.data?.rows, rows.count > 0 else {
            return
        }
        print("sheet data rows is:\(rows)")
        
        let parseBooks = try? file.parseWorkbooks();
        for wbk in parseBooks ?? []
        {
            for (name, path) in try! file.parseWorksheetPathsAndNames(workbook: wbk) {
                if let worksheetName = name {
                    print("This worksheet has a name: \(worksheetName)")
                }
                
                let worksheet = try! file.parseWorksheet(at: path)
                let parseSharedStrings = try? file.parseSharedStrings();
                let worksheet_rows:[Row] = worksheet.data!.rows;
                var rowNumber = 0;//第几行
                var rowText = "";//第几行对应的文字
                var columnNumber: Int = 0;//第几列
                var columnText = "";//第几列对应的文字
                rowInfoArray = [RowInfoModel]()
                var rowInfoDictionary: RowInfoModel?
                var lastRowNumber: Int = 0
                
                for subRow in worksheet_rows {
                    
                    columnNumber = Int(subRow.reference);//第几列
                    for subCell in subRow.cells {
                        rowNumber = Int(subCell.reference.row);//第几行
                        rowText = subCell.stringValue(parseSharedStrings!) ?? "";//第几行对应的文字
                        columnText = subCell.reference.column.value;//第几列对应的文字
//                        columnNumber = subCell.reference.column.intValue
                        print("第"+String(rowNumber)+"行：" + "  第" + String(columnNumber)+"列：" + "    行信息：" + rowText + "   列信息：" + columnText);
                        
                        if lastRowNumber != columnNumber {
                            lastRowNumber = columnNumber
                            rowInfoDictionary = RowInfoModel()
                            rowInfoDictionary?.rowId = String(columnNumber)
                        }
                        if columnText == "A" {
                            rowInfoDictionary?.cityName = rowText
                        }
                        else if columnText == "B" {
                            rowInfoDictionary?.cCode = rowText
                        }
                        else if columnText == "C" {
                            rowInfoDictionary?.cityCode = rowText
                            rowInfoArray?.append(rowInfoDictionary!)
                        }
                    }
                    
                }
            }
            
        }
        
        for item in self.rowInfoArray! {
            for info in self.districts {
                if item.cityName!.contains(info) {
                    self.cityCodes?.append(item.cityCode!)
                    break
                }
            }
            
        }
        
        Task.init{
            do {
                self.dataArray = try await multiWeatherInfoLoad(cityCodes: self.cityCodes!)
            } catch {
                
            }
        }
    }
    
    func multiWeatherInfoLoad(cityCodes: [String]) async -> [WeatherModel] {
        var results: [WeatherModel] = []
        
        await withTaskGroup(of: WeatherModel.self, body: { taskGroup in
            for item in cityCodes {
                taskGroup.addTask {
                    return await self.loadWeatherInfo(cityCode: item)
                }
            }
            
            for await result in taskGroup {
                results.append(result)
            }
        })
        
        return results
    }
    
    
    func loadWeatherInfo(cityCode: String) -> WeatherModel {
        var model: WeatherModel? = WeatherModel()
        let url: String = String("\(WeatherReqUrl)city=\(cityCode)&key=\(GDKey)")
        
        Alamofire.request(url).responseJSON { response in
            print("data is: \(response.data)")
        }
        
        return model!
    }

}


extension WeatherListController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.districts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: WeatherItemCell = tableView.dequeueReusableCell(withIdentifier: "WeatherItemCell", for: indexPath) as! WeatherItemCell
        
        return cell
    }
    
    
}

class RowInfoModel: NSObject {
    var rowId: String?
    var cityName: String?
    var cityCode: String?
    var cCode: String?
    
}
