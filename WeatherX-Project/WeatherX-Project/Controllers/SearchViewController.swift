//
//  SearchViewController.swift
//  WeatherX-Project
//
//  Created by Insu on 9/27/23.
//

import UIKit
import Then
import SnapKit
import MapKit

protocol SearchViewControllerDelegate: AnyObject {
    func didAddCity(_ city: String, coordinate: CLLocationCoordinate2D)
}

final class SearchViewController: UISearchController {
    
    // MARK: - Properties
    
    weak var searchDelegate: SearchViewControllerDelegate?
    
    var citySearchTableView = UITableView().then {
        $0.register(SearchListTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private var searchCompleter: MKLocalSearchCompleter = .init()
    private var searchResults: [MKLocalSearchCompletion] = .init() {
        didSet {
            DispatchQueue.main.async {
                self.citySearchTableView.reloadData()
            }
        }
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        obscuresBackgroundDuringPresentation = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.placeholder = "도시 검색"
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        
        citySearchTableView.delegate = self
        citySearchTableView.dataSource = self
        searchBar.delegate = self
        searchCompleter.delegate = self
        
        view.addSubview(citySearchTableView)
        citySearchTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func updateSearchResults(selected: MKLocalSearchCompletion) {
        // 검색 로직 구현
        let searchRequest = MKLocalSearch.Request(completion: selected)
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            if error != nil {
                print("requestFailed")
            }
            
            let coordinate = response?.mapItems.first?.placemark.coordinate
            let name = response?.mapItems.first?.name
            guard let coordinate = coordinate, let name = name else { return }
            self.searchDelegate?.didAddCity(name, coordinate: coordinate)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchListTableViewCell
        cell.config(data: searchResults[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateSearchResults(selected: searchResults[indexPath.row])
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchText = searchBar.text,
              searchText.count > 0
        else {
            searchResults.removeAll()
            return
        }
        // 부분 입력으로 자동 검색결과 생성
        searchCompleter.queryFragment = searchText
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = true
        searchBar.becomeFirstResponder()
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension SearchViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.searchResults = completer.results.filter { result in
            
            let title = result.title

            if (title.contains("시") || title.contains("구")) &&
                !(title.contains("동") || title.contains("면") || title.contains("리") || title.contains("로")) {
                return true
            }
            
            if !title.contains(",") || result.title.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
                return false
            }
            
            
            return true
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("requestFailed")
    }
}
