//
//  WeatherTableViewCell.swift
//  WeatherX-Project
//
//  Created by Insu on 2023/09/25.
//

import UIKit
import SnapKit

final class WeatherTableViewCell: UITableViewCell {
    
    let dateNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "25"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    let dateTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Tue"
        label.textColor = .lightGray
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    lazy var dayStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [dateNumberLabel, dateTextLabel])
        sv.axis = .vertical
        sv.distribution  = .fill
        sv.alignment = .fill
        sv.spacing = 5
        return sv
    }()
    
    let percentTextLabel: UILabel = {
        let label = UILabel()
        label.text = "💧"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    let weatherImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.frame.height / 2
        return imageView
    }()
    
    lazy var weatherContainView: UIView = {
        let uiView = UIView()
        uiView.addSubview(weatherImageView)
        uiView.addSubview(percentTextLabel)
        return uiView
    }()
    
    let lowTemperTextLabel: UILabel = {
        let label = UILabel()
        label.text = "13℃"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    let lowTemperImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "arrowshape.down.fill")
        imageView.tintColor = .systemBlue
        imageView.layer.opacity = 0.7
        return imageView
    }()
    
    lazy var lowTemperContainView: UIView = {
        let uiView = UIView()
        uiView.addSubview(lowTemperImageView)
        uiView.addSubview(lowTemperTextLabel)
        return uiView
    }()
    
    let hightTemperTextLabel: UILabel = {
        let label = UILabel()
        label.text = "27℃"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    let hightTemperImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "arrowshape.up.fill")
        imageView.tintColor = .systemRed
        imageView.layer.opacity = 0.7
        return imageView
    }()
    
    lazy var hightTemperContainView: UIView = {
        let uiView = UIView()
        uiView.addSubview(hightTemperImageView)
        uiView.addSubview(hightTemperTextLabel)
        return uiView
    }()
    
    let slashTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = "|"
        return label
    }()
    
    lazy var temperatureStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [lowTemperContainView, slashTextLabel, hightTemperContainView])
        sv.axis = .horizontal
        sv.distribution  = .fillEqually
        sv.alignment = .fill
        sv.spacing = 20
        return sv
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        cellLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func cellLayout() {
        self.addSubview(dayStackView)
        self.addSubview(weatherContainView)
        self.addSubview(temperatureStackView)
        
        //요일 레이아웃
        dateTextLabel.snp.makeConstraints {
            $0.centerX.equalTo(dateNumberLabel.snp.centerX)
        }
        dayStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(15)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        weatherImageView.snp.makeConstraints {
            $0.centerX.equalTo(weatherContainView)
            $0.centerY.equalTo(weatherContainView)
            $0.height.width.equalTo(70)
        }
        
        percentTextLabel.snp.makeConstraints {
            $0.centerX.equalTo(weatherContainView).offset(12)
            $0.centerY.equalTo(weatherContainView).offset(15)
        }
        
        weatherContainView.snp.makeConstraints {
//            $0.top.equalToSuperview().offset(10)
//            $0.leading.equalTo(dayStackView.snp.trailing).offset(60)
//            $0.bottom.equalToSuperview().offset(-10)
            $0.centerX.equalToSuperview().offset(-50)
            $0.centerY.equalToSuperview()
        }
        
        lowTemperImageView.snp.makeConstraints {
            $0.centerX.equalTo(lowTemperContainView).offset(-13)
            $0.centerY.equalTo(lowTemperContainView).offset(10)
            $0.width.height.equalTo(27)
        }
        
        lowTemperTextLabel.snp.makeConstraints {
            $0.centerX.equalTo(lowTemperContainView)
            $0.centerY.equalTo(lowTemperContainView)
        }
        
        hightTemperImageView.snp.makeConstraints {
            $0.centerX.equalTo(hightTemperContainView).offset(12)
            $0.centerY.equalTo(hightTemperContainView).offset(-10)
            $0.width.height.equalTo(27)
        }
        
        slashTextLabel.snp.makeConstraints {
            $0.centerX.equalTo(temperatureStackView).offset(12)
            $0.centerY.equalTo(temperatureStackView)
        }
        
        hightTemperTextLabel.snp.makeConstraints {
            $0.centerX.equalTo(hightTemperContainView).offset(-3)
            $0.centerY.equalTo(hightTemperContainView)
        }
        
        temperatureStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.bottom.equalToSuperview().offset(-10)
            $0.width.equalTo(100)
            $0.height.equalTo(40)
        }
        
    }
    
    
}
