//
//  ViewController.swift
//  GooglePictures
//
//  Created by Ivan on 12.04.2024.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {

    let searchBar = UISearchBar()
    var activityIndicator = UIActivityIndicatorView()
    var searchText: String = ""
    var page = 0
    
    var apiHelper = ApiHelper()
    
    var items: [UIImage] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Search"
        searchBar.delegate = self
        view.addSubview(searchBar)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        activityIndicator = UIActivityIndicatorView(style: .medium)
        self.view.addSubview(activityIndicator)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            searchBar.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.widthAnchor.constraint(equalToConstant: 25),
            activityIndicator.heightAnchor.constraint(equalToConstant: 25),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchBar.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.frame.size.width-20, height: 50)
    }
    
    // -----
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        // Reset the page variable and clear items array when a new search is initiated.
        guard let searchBarText = searchBar.text, !searchBarText.isEmpty else { return }
        searchText = searchBarText
        page = 0                     
        items = []
        collectionView.reloadData()
        
        fetchPicture(withQuery: searchBarText)
    }
    
    func fetchPicture(withQuery query: String) {
        self.activityIndicator.startAnimating()
        let startElementOnPage = (page * 10) + 1
        print("Fetching page \(page + 1) starting at element \(startElementOnPage)")
        
        guard let url = buildURL(withQuery: query, startElementOnPage: startElementOnPage) else {
            self.activityIndicator.stopAnimating()
            return
        }
        
        apiHelper.makeUrlRequest(url: url) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let data):
                    self?.handleResponseData(data: data, query: query)
                case .failure(let error):
                    self?.handleError(error, query: query)
                }
            }
        }
    }

    private func buildURL(withQuery query: String, startElementOnPage: Int) -> URL? {
        var url = URL(string: "https://www.googleapis.com/customsearch/v1")
        url?.append(queryItems: [URLQueryItem(name: "key", value: "AIzaSyD-ZkNR3zkwYhY4uK2EdoFXnJbfCZLIzXA"),
                                 URLQueryItem(name: "cx", value: "c6f64a506feec48ec"),
                                 URLQueryItem(name: "searchType", value: "image"),
                                 URLQueryItem(name: "q", value: query),
                                 URLQueryItem(name: "start", value: "\(startElementOnPage)")
                                ])
        return url
    }
    
    private func handleError(_ error: Error?, query: String) {
        print(error?.localizedDescription ?? "Unknown error")
        if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
            self.activityIndicator.stopAnimating()    // ?????????
            self.noInternetAlert()
        } else {
            self.fetchPicture(withQuery: query)
        }
    }

    private func handleResponseData(data: Data, query: String) {
        do {
            let jsonResult = try JSONDecoder().decode(GetPicture.self, from: data)
            print("Received \(jsonResult.items.count) items from API")
            jsonResult.items.forEach { link in
                guard link.link.hasPrefix("https") else { return }
                    apiHelper.makePictureRequest(imageLink: link.link) { [weak self] result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let data):
                                guard let image = UIImage(data: data) else { return }
                                self?.items.append(image)
                                self?.collectionView.reloadData()
                            case .failure(let error):
                                self?.errorAlert(with: error)
                            }
                        }
                    }
                }
            
            self.activityIndicator.stopAnimating()
        } catch {
            self.activityIndicator.stopAnimating()
            self.errorAlert(with: error) { [weak self] in
                self?.fetchPicture(withQuery: query)
            }
        }
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCollectionViewCell", for: indexPath) as? ItemCollectionViewCell else { return UICollectionViewCell() }
        
        let imageUrlString = items[indexPath.item]
        cell.configure(with: imageUrlString)
        
        if indexPath.item == items.count - 1 {  // check if you scrolled to the end of items array but indexPath.item is still less then 10
            page += 1
            fetchPicture(withQuery: searchText)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 170 ,height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPicture = items[indexPath.item]
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        guard let destination = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {
            return
        }
        destination.picture = selectedPicture
        navigationController?.pushViewController(destination, animated: true)
    }
}

