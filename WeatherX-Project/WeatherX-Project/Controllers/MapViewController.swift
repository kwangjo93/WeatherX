//
//  MapViewController.swift
//  WeatherX-Project
//
//  Created by Insu on 2023/09/25.
//

import UIKit
import MapKit
import Then

final class MapViewController: UIViewController {
    
    private var mapView: MKMapView!
    private var selectedAction: String = "기온" // 기본값
    private var rightBarButton: UIBarButtonItem!
    
    var weatherResponse: WeatherResponse?
    var weatherList: [WeatherResponse] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        configureNav()
        updateUserLocation()
        setMyLocation()
    }
}

private extension MapViewController {
    
    func setupMapView() {
        mapView = MKMapView(frame: view.bounds)
        mapView.delegate = self
        view.addSubview(mapView)
        mapView.mapType = .hybridFlyover
    }
    
    func setMyLocation() {
        guard let lat = self.weatherResponse?.coord.lat, let lon = self.weatherResponse?.coord.lon else { return }
        let initialLocation = CLLocation(latitude: lat, longitude: lon)
        let regionRadius: CLLocationDistance = 120000
        let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate,
                                                          latitudinalMeters: regionRadius,
                                                          longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func updateUserLocation() {
        if let lat = self.weatherResponse?.coord.lat, let lon = self.weatherResponse?.coord.lon {
            let userLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let annotation = MKPointAnnotation()
            annotation.coordinate = userLocation
            annotation.title = self.weatherResponse?.name
            mapView.addAnnotation(annotation)
            mapView.setCenter(userLocation, animated: true)
        } else {
            print("coord가 nil입니다.")
        }
        
        guard let weatherResponse else { return }
        weatherList.append(weatherResponse)
        
        for weather in weatherList {
            let latitude = weather.coord.lat
            let longitude = weather.coord.lon
            let userLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = userLocation
            annotation.title = weather.name
            mapView.addAnnotation(annotation)
            
            mapView.setCenter(userLocation, animated: true)
        }
    }
    
    func configureNav() {
        let doneButton = UIBarButtonItem(title: "완료",
                                         style: .plain,
                                         target: self,
                                         action: #selector(doneButtonTapped))
        doneButton.tintColor = .black
        navigationItem.leftBarButtonItem = doneButton
        
        rightBarButton = UIBarButtonItem(image: UIImage(systemName: "square.3.stack.3d"), style: .plain, target: nil, action: nil)
        rightBarButton.menu = createMenu()
        rightBarButton.tintColor = .black
        navigationItem.rightBarButtonItem = rightBarButton
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    @objc func doneButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func createMenu() -> UIMenu {
        let tempAction = UIAction(title: "기온",
                                  image: UIImage(systemName: "thermometer.medium"),
                                  state: selectedAction == "기온" ? .on : .off,
                                  handler: { [weak self] _ in
            self?.handleTemperature()
        })
        
        let windAction = UIAction(title: "바람",
                                  image: UIImage(systemName: "wind"),
                                  state: selectedAction == "바람" ? .on : .off,
                                  handler: { [weak self] _ in
            self?.handleWind()
        })
        
        let precipitation = UIAction(title: "강수량",
                                     image: UIImage(systemName: "umbrella"),
                                     state: selectedAction == "강수량" ? .on : .off,
                                     handler: { [weak self] _ in
            self?.handlePrecipitation()
        })
        
        return UIMenu(title: "", children: [tempAction, windAction, precipitation])
    }
    
    func handleTemperature() {
        selectedAction = "기온"
        rightBarButton.menu = createMenu()
        updateAnnotationViews()
    }
    
    func handleWind() {
        selectedAction = "바람"
        rightBarButton.menu = createMenu()
        updateAnnotationViews()
    }
    
    func handlePrecipitation() {
        selectedAction = "강수량"
        rightBarButton.menu = createMenu()
        updateAnnotationViews()
    }
    
    func updateAnnotationViews() {
        mapView.removeAnnotations(mapView.annotations)
        updateUserLocation()
        mapView.setNeedsDisplay()
    }
    
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "CustomMarker")
        
        guard let annotationTitle = annotation.title, let weather = weatherList.first(where: { $0.name == annotationTitle }) else {
            return annotationView
        }
        switch selectedAction {
        case "기온":
            let temp = weather.main.temp
               annotationView.glyphText = "\(temp)°"
        case "바람":
            if let windSpeed = weather.wind.speed {
                annotationView.glyphText = "\(windSpeed) m/s"
            }
        case "강수량":
            if let icon = weather.weather.first?.icon,
               let iconURL = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png") {
                downloadImage(fromURL: iconURL) { image in
                    DispatchQueue.main.async {
                        annotationView.glyphImage = image
                    }
                }
                annotationView.glyphImage = UIImage()
            }
        default:
            break
        }
        return annotationView
    }
}

// 이미지 다운로드
private extension MapViewController {
    func downloadImage(fromURL url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error downloading image: \(error)")
                completion(nil)
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
}
