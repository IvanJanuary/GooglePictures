//
//  ApiHelper.swift
//  GooglePictures
//
//  Created by Ivan on 02.05.2024.
//

import Foundation

struct ApiHelper {
    
    func makeUrlRequest(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Request error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                return
            }
            
            completion(.success(data))
        }
        
        task.resume()
    }
    
    func makePictureRequest(imageLink: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: imageLink) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return }
        makeUrlRequest(url: url, completion: completion)
    }
}
