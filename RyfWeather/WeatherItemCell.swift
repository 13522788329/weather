//
//  WeatherItemCell.swift
//  RyfWeather
//
//  Created by renyafang on 2023/4/16.
//

import UIKit

class WeatherItemCell: UITableViewCell {

    lazy var cityName: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.white
        label.frame = CGRect(x: 16, y: 12, width: 100, height: 20)
        return label
    }()
    
    var model: WeatherModel?
    
    
    lazy var weatherDetailLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.gray
        label.frame = CGRect(x: 16, y: 70, width: 100, height: 15)
        return label
    }()
    
    lazy var temperatureLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = UIColor.white
        label.frame = CGRect(x: self.frame.size.width - 100, y: 12, width: 100, height: 20)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView()
    {
        self.backgroundColor = .clear
        self.contentView.addSubview(self.cityName)
        self.contentView.addSubview(self.weatherDetailLabel)
        self.contentView.addSubview(self.temperatureLabel)
        
        let publisher = self.cityName.publisher(for: \.text, options: NSKeyValueObservingOptions.new)

        publisher.sink { [weak self](text) in
            self?.model?.city = self?.cityName.text
        }
    }
    
    func updateInfo(model: WeatherModel) {
        self.model = model
        self.updateViews()
    }
    
    func updateViews() {
        if let city_name = self.model?.city {
            self.cityName.text = city_name
        }
        
        if let weather_detail = self.model?.weather {
            self.weatherDetailLabel.text = weather_detail
        }
        
        if let temperature = self.model?.temperature {
            self.temperatureLabel.text = temperature + "C"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
