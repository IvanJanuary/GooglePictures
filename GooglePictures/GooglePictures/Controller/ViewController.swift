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
    var page = 1
    
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
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        self.view.addSubview(activityIndicator)
        
        activityIndicatorConstraint()
    }
    
    func activityIndicatorConstraint() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.widthAnchor.constraint(equalToConstant: 25).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 25).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchBar.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.frame.size.width-20, height: 50)
    }
    
    // -----
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let searchBarText = searchBar.text else { return }
        page = 1
        searchText = searchBarText
        items = []
        collectionView.reloadData()
        
        fetchPicture(withQuery: searchBarText)
    }
    
    func fetchPicture(withQuery query: String) {
        self.activityIndicator.startAnimating()
        let startElementOnPage = (page * 10) + 1
        
        guard let url = buildURL(withQuery: query, startElementOnPage: startElementOnPage) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                self?.handleError(error, query: query)
                return
            }
            
            guard let data = data else {
                self?.handleError(nil, query: query)
                return
            }
            
            self?.handleResponseData(data: data, query: query)
        }
        
        task.resume()
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
        DispatchQueue.main.async { [weak self] in
            if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
                self?.activityIndicator.stopAnimating()
                self?.noInternetAlert()
            } else {
                self?.fetchPicture(withQuery: query)
            }
        }
    }

    private func handleResponseData(data: Data, query: String) {
        do {
            let jsonResult = try JSONDecoder().decode(GetPicture.self, from: data)
            jsonResult.items.forEach { link in
                guard let pictureUrl = URL(string: link.link) else { return }
                URLSession.shared.dataTask(with: pictureUrl) { [weak self] data, _, error in
                    guard let data = data, error == nil, let image = UIImage(data: data) else { return }
                    DispatchQueue.main.async {
                        self?.items.append(image)
                        self?.collectionView.reloadData()
                    }
                }.resume()
            }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        } catch {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.errorAlert(with: error, completion: { [weak self] in
                    self?.fetchPicture(withQuery: query)
                })
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
        
        if (indexPath.item + 1) % 10 == 0 && indexPath.item == items.count - 1 {
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

