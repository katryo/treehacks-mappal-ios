//
//  WebClient.swift
//  EventTicket
//
//  Created by RYOKATO on 2018/11/24.
//  Copyright © 2018 Denkinovel. All rights reserved.
//

import Foundation

class WebClient {
    static func getWithParam(urlString: String,
                             param: String,
                             paramValue: String,
                      noData: @escaping () -> Void = {},
                      not200: @escaping (HTTPURLResponse) -> Void = {_ in },
                      failure: @escaping (Error)-> Void = {_ in},
                      success: @escaping (Data)-> Void = {_ in}) {
        let baseUrl = URL(string: urlString)!
        var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: param, value: paramValue)]
        let url = components.url!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            print(url)
            if let error = error {
                // TODO: Error handling
                print("Error: \(error.localizedDescription) \n")
                failure(error)
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                print("No data or no response")
                noData()
                // TODO: Error handling
                return
            }
            
            if response.statusCode == 200 {
                success(data)
            } else {
                // TODO: Error handling
                print("Status code: \(response.statusCode)\n")
                not200(response)
            }
        }
        task.resume()
    }

    
    static func fetch(urlString: String,
                      lat: Double,
                      lng: Double,
                      noData: @escaping () -> Void = {},
                      not200: @escaping (HTTPURLResponse) -> Void = {_ in },
                      failure: @escaping (Error)-> Void = {_ in},
                      success: @escaping (Data)-> Void = {_ in}) {
        let baseUrl = URL(string: urlString)!
        var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)!
        
        components.queryItems = [URLQueryItem(name: "lat", value: String(lat)),
                                 URLQueryItem(name: "lng", value: String(lng))]
        let url = components.url!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            print(url)
            if let error = error {
                // TODO: Error handling
                print("Error: \(error.localizedDescription) \n")
                failure(error)
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                print("No data or no response")
                noData()
                // TODO: Error handling
                return
            }
            
            if response.statusCode == 200 {
                success(data)
            } else {
                // TODO: Error handling
                print("Status code: \(response.statusCode)\n")
                not200(response)
            }
        }
        task.resume()
    }
}
