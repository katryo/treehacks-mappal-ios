//
//  ViewController.swift
//  treehacks-mappal-ios
//
//  Created by RYOKATO on 2019/02/16.
//  Copyright © 2019 mappal. All rights reserved.
//

import UIKit
import CoreLocation
import WebKit

// https://stackoverflow.com/questions/47300435/update-location-in-background
// https://www.raywenderlich.com/5817-background-modes-tutorial-getting-started

class ViewController: UIViewController, CLLocationManagerDelegate, WKUIDelegate {
    let locationManager = CLLocationManager()
        // https://developer.apple.com/documentation/webkit/wkwebview
    
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    @IBAction func okButtonClicked(_ sender: UIButton) {
        print("OK!")
        WebClient.getWithParam(
            urlString: "https://treehacks-mappal.appspot.com/send_okay_sms",
                        param: "address",
                        paramValue: "somewhere",
                        noData: {
                            print("nodata")
        },
                        not200: {_ in
                            print("not200")
        },
                        failure: {_ in
                            print("failure")
        },
                        success: {_ in
                            print("Sent SMS okay.")
        })
    }
    
    @IBAction func helpMeButtonClicked(_ sender: UIButton) {
        WebClient.getWithParam(
            urlString: "https://treehacks-mappal.appspot.com/send_help_sms",
            param: "address",
            paramValue: "somewhere",
            noData: {
                print("nodata")
        },
            not200: {_ in
                print("not200")
        },
            failure: {_ in
                print("failure")
        },
            success: {_ in
                print("Sent SMS okay.")
        })
        print("Sent SMS to the parent")
    }
    
    let decoder = JSONDecoder()
    
    @IBOutlet weak var securityScoreLabel: UILabel!
    var securityScore: SecurityScore? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        

        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()

    }
    
    
    
//    override func loadView() {
//        let webConfiguration = WKWebViewConfiguration()
//        webView = WKWebView(frame: .zero, configuration: webConfiguration)
//        webView.uiDelegate = self
//        view = webView
//    }
    
    @objc func alert() {
        print("send an SMS message to the parent")
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            print("latitude:\(location.coordinate.latitude) longitude:\(location.coordinate.longitude) time:\(location.timestamp.description)")
            // TODO: address
            fetchSecurityScore(lat: location.coordinate.latitude,
                               lng: location.coordinate.longitude,
                               address: "1234 Stanford, CA, 10000",
                               finished: {
                    print("Update security score view...")
                                
                                if self.securityScore!.score < 0.3 {
                                            Timer.scheduledTimer(timeInterval: 1000, target: self,
                                                selector: #selector(ViewController.alert), userInfo: nil,
                                                                 repeats: false)
                                }
                                
                            DispatchQueue.main.async {
                                self.securityScoreLabel.text = "Security score:" + String(self.securityScore!.score)
            }
            }, failed: {
                print("Failed to update security score")
            })
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("Not yet determined")
            locationManager.requestWhenInUseAuthorization()
            break
        case .denied:
            print("No location")
            break
        case .restricted:
            print("Can not locate the device")
            break
        case .authorizedAlways:
            print("Location detection is authorized")
            break
        case .authorizedWhenInUse:
            print("authorized when in use")
            break
        }
    }
    
//    func registerBackgroundTask() {
//        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
//            self?.endBackgroundTask()
//        }
//        assert(backgroundTask != .invalid)
//    }
//
//    func endBackgroundTask() {
//        print("Background task ended.")
//        UIApplication.shared.endBackgroundTask(backgroundTask)
//        backgroundTask = .invalid
//    }
    
    
    private func fetchSecurityScore(lat: Double,
                                    lng: Double,
                                    address: String,
         finished: @escaping () -> Void,
         failed: @escaping () -> Void) {
        WebClient.fetch(urlString: "https://treehacks-mappal.appspot.com/security_score",
                        lat: lat,
                        lng: lng,
                        address: address,
                        noData: {
                            print("nodata")
                            failed()
        },
                        not200: {_ in
                            print("not200")
                            failed()
        },
                        failure: {_ in
                            print("failure")
                            failed()
        },
                        success: {data in
                            let decoder = JSONDecoder()
                            do {
                                self.securityScore = try decoder.decode(SecurityScore.self, from: data)
                                finished()
                            } catch {
                                print("Failed to decode the JSON", error)
                                failed()
                            }
        })
    }

}

