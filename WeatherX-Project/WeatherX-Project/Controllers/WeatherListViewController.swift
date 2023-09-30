//
//  WeatherListViewController.swift
//  WeatherX-Project
//
//  Created by Insu on 2023/09/25.
//

import UIKit
import Then
import SnapKit
import CoreLocation

class WeatherListViewController: UIViewController {

    // MARK: - Properties

    private var temperatureUnit = "섭씨"
    private var rightBarButton: UIBarButtonItem!
    private let searchController = SearchViewController(searchResultsController: nil)
    var weatherData: [WeatherResponse] = []

    private let weatherListTableView = UITableView().then {
        $0.backgroundColor = .white
        $0.register(WeatherListCell.self, forCellReuseIdentifier: "WeatherListCell")
    }

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNav()
        configureUI()
    }

    // MARK: - Helpers

    private func configureNav() {
        navigationItem.title = "날씨"
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        rightBarButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: nil, action: nil)
        rightBarButton.menu = createMenu()
        rightBarButton.tintColor = UIColor.black
        navigationItem.rightBarButtonItem = rightBarButton

        let appearance = UINavigationBarAppearance().then {
            $0.configureWithOpaqueBackground()
            $0.backgroundColor = .white
            $0.largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 28, weight: .semibold), .foregroundColor: UIColor.label]
            $0.titleTextAttributes = [.foregroundColor: UIColor.label]
            $0.shadowColor = nil
        }

        let scrollAppearance = UINavigationBarAppearance().then {
            $0.configureWithOpaqueBackground()
            $0.backgroundColor = .white
            $0.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
            $0.titleTextAttributes = [.foregroundColor: UIColor.label]
            $0.shadowColor = nil
        }

        // backbutton 임시로 배치
        navigationController?.navigationBar.topItem?.title = ""
        navigationController?.navigationBar.tintColor = .black

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.standardAppearance = scrollAppearance
        navigationController?.navigationBar.compactAppearance = scrollAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func configureUI() {
        searchController.searchDelegate = self
        weatherListTableView.delegate = self
        weatherListTableView.dataSource = self

        view.addSubview(weatherListTableView)
        weatherListTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func createMenu() -> UIMenu {
        let editAction = UIAction(title: "목록 편집", image: UIImage(systemName: "pencil"), handler: handleEditAction(_:))
        let tempAction = UIMenu(title: "", options: .displayInline, children: [
            UIAction(title: "섭씨", image: UIImage(named: "celsius"), state: temperatureUnit == "섭씨" ? .on : .off, handler: handleCelsiusAction(_:)),
            UIAction(title: "화씨", image: UIImage(named: "fahrenheit"), state: temperatureUnit == "화씨" ? .on : .off, handler: handleFahrenheitAction(_:))
        ])
        let unitAction = UIAction(title: "단위", image: UIImage(systemName: "chart.bar"), handler: handleUnitAction(_:))
        return UIMenu(title: "", children: [editAction, tempAction, unitAction])
    }

    // MARK: - Actions

    private func handleEditAction(_ action: UIAction) {
        // 추가된 셀 지우는 기능 추가
    }

    private func handleCelsiusAction(_ action: UIAction) {
        temperatureUnit = "섭씨"
        rightBarButton.menu = createMenu()
        weatherListTableView.reloadData()
    }

    private func handleFahrenheitAction(_ action: UIAction) {
        temperatureUnit = "화씨"
        rightBarButton.menu = createMenu()
        weatherListTableView.reloadData()
    }

    private func handleUnitAction(_ action: UIAction) {
        let weatherUnitViewController = WeatherUnitViewController()
        let navController = UINavigationController(rootViewController: weatherUnitViewController)
        present(navController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension WeatherListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherListCell", for: indexPath) as! WeatherListCell
        let weatherInfo = weatherData[indexPath.row]
        cell.cityLabel.text = weatherInfo.name
        let temperature = weatherInfo.main.temp
        if temperatureUnit == "섭씨" {
            cell.temperatureLabel.text = "\(Int(temperature))°C"
        } else {
            cell.temperatureLabel.text = "\(Int(temperature * 9 / 5 + 32))°F"
        }
        cell.weatherDescriptionLabel.text = weatherInfo.weather.first?.description
        // cell.weatherImageView.image = ... // 여기다가 날씨 이미지 설정하면 되는데... 고민중..
        cell.timeLabel.text = DateFormat.dateString
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension WeatherListViewController: SearchViewControllerDelegate {
    func didAddCity(_ city: String, coordinate: CLLocationCoordinate2D) {
        Networking.shared.lat = coordinate.latitude
        Networking.shared.lon = coordinate.longitude
        Networking.shared.getWeather { result in
            switch result {
            case .success(let weatherResponse):
                DispatchQueue.main.async {
                    self.weatherData.append(weatherResponse)
                    self.weatherListTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
