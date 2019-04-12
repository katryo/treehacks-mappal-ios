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
import GoogleMaps
import GooglePlaces
import Toast_Swift
import UserNotifications

// https://stackoverflow.com/questions/47300435/update-location-in-background
// https://www.raywenderlich.com/5817-background-modes-tutorial-getting-started

class ViewController: UIViewController, CLLocationManagerDelegate, WKUIDelegate, UNUserNotificationCenterDelegate {
    let locationManager = CLLocationManager()
        // https://developer.apple.com/documentation/webkit/wkwebview
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var newsLabel: UILabel!
    
    var isDangerous = false
    
    @IBAction func clockButtonClicked(_ sender: UIButton) {
        fun()
    }
    
    @objc
    private func fun() {
        sendHelpSMS()
        let alertController = UIAlertController(
            title: "HELP message has been sent",
            message: "10 minutes have been passed after you entered the statistically dangerous zone.",
            preferredStyle: UIAlertController.Style.alert
        )
        
        let cancelAction = UIAlertAction(
            title: "Dismiss",
            style: UIAlertAction.Style.default) { (action) in
        }
        
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    @IBAction func okButtonClicked(_ sender: UIButton) {
        sendOKSMS()
    }
    
    private func sendOKSMS() {
        let address: String
        if self.securityScore != nil {
            address = self.securityScore!.address
        } else {
            address = "not sure"
        }
        WebClient.getWithParam(
            urlString: "https://treehacks-mappal.appspot.com/send_okay_sms",
            param: "address",
            paramValue: address,
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
                print("Sent an OK SMS.")
                DispatchQueue.main.async {
                    self.view.makeToast("Sent an OK SMS")
                }
        })
    }
    
    @IBAction func helpMeButtonClicked(_ sender: UIButton) {
        sendHelpSMS()
        print("Sent SMS to the parent")
    }
    
    let decoder = JSONDecoder()
    
    @IBOutlet weak var securityScoreLabel: UILabel!
    var securityScore: SecurityScore? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        

        updateMap()
        self.mapView.isMyLocationEnabled = true
        self.mapView.mapType = .normal
        
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        Timer.scheduledTimer(timeInterval: 60, target: self,
                                                        selector: #selector(ViewController.fun), userInfo: nil,
                                                                         repeats: true)
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }
    

    @objc private func showQuestion() {
            let alertController = UIAlertController(
                title: "Are You OK?",
                message: "You entered a statistically dangerous zone.",
                preferredStyle: UIAlertController.Style.alert
            )
            
            let cancelAction = UIAlertAction(
                title: "Help me",
                style: UIAlertAction.Style.destructive) { (action) in
                    self.sendHelpSMS()
            }
            
            let confirmAction = UIAlertAction(
            title: "OK", style: UIAlertAction.Style.default) { (action) in
                self.sendOKSMS()
            }
            
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
    }

    
    private func updateMap() {
        let lat: Double
        let lng: Double
        if locationManager.location != nil {
            lat = locationManager.location!.coordinate.latitude
            lng = locationManager.location!.coordinate.longitude
        } else {
            lat = 34.052235
            lng = -118.243683
        }
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 10)
        self.mapView.camera = camera

        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 34.052235, longitude: -118.243683)
        marker.map = self.mapView
    }
    
    
    
//    override func loadView() {
//        let webConfiguration = WKWebViewConfiguration()
//        webView = WKWebView(frame: .zero, configuration: webConfiguration)
//        webView.uiDelegate = self
//        view = webView
//    }
    
    @objc func alert() {
        sendHelpSMS()
        print("send an SMS message to the parent")
    }
    
    private func sendHelpSMS() {
        let address: String
        if self.securityScore != nil {
            address = self.securityScore!.address
        } else {
            address = "not sure"
        }
        WebClient.getWithParam(
            urlString: "https://treehacks-mappal.appspot.com/send_help_sms",
            param: "address",
            paramValue: address,
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
                print("Sent a HELP SMS.")
                DispatchQueue.main.async {
                    self.view.makeToast("Sent an OK SMS")
                }
        })
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {

            fetchSecurityScore(lat: location.coordinate.latitude,
                               lng: location.coordinate.longitude,
                               finished: {
                    print("Update security score view...")
                                
                                if self.securityScore!.score > 0.6 {
                                    if !self.isDangerous {
                                        DispatchQueue.main.async {
                                            self.showQuestion()
                                        }
                                        self.isDangerous = true
                                    }

                                } else {
                                    self.isDangerous = false
                                }
                                
                            DispatchQueue.main.async {
                                self.updateMap()
                                
                                if self.securityScore!.score > 0.6 {
                                    self.securityScoreLabel.text = "Security score: " + String(self.securityScore!.score) + " 😨"
                                } else {
                                    self.securityScoreLabel.text = "Security score: " + String(self.securityScore!.score) + " 😄"
                                }
                                self.addressLabel.text = String(self.securityScore!.address)
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
    
    
    private func fetchSecurityScore(lat: Double,
                                    lng: Double,
         finished: @escaping () -> Void,
         failed: @escaping () -> Void) {
        WebClient.fetch(urlString: "https://treehacks-mappal.appspot.com/security_score",
                        lat: lat,
                        lng: lng,
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

