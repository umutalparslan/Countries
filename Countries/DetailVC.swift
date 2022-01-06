//
//  DetailVC.swift
//  Countries
//
//  Created by Umut Can Alparslan on 4.01.2022.
//

import Alamofire
import SwiftyJSON
import UIKit
import WebKit

class DetailVC: UIViewController {
    var code: String?
    var wikiDataId: String?
    var name: String?
    @IBOutlet var countryImageView: UIView!
    @IBOutlet var ccLabel: UILabel!
    @IBOutlet var detailButton: UIButton!
    @IBOutlet var savedButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let countryCode = code {
            ccLabel.text = countryCode
            getCountryDetails(countryCode: countryCode, host: ViewController.host, key: ViewController.key, url: "\(ViewController.uri)/\(countryCode)")
        }
        if let countryName = name {
            title = countryName
            if SCArray.name.contains(countryName) {
                savedButton.image = UIImage(named: "saved")
            } else {
                savedButton.image = UIImage(named: "unsaved")
            }
        }

        countryImageView.isUserInteractionEnabled = false
        if #available(iOS 15.0, *) {
            var conf = UIButton.Configuration.plain()
            conf.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
            detailButton.configuration = conf
        } else {
            detailButton.contentEdgeInsets.right = 10
            detailButton.contentEdgeInsets.left = 10
        }
    }

    @IBAction func backButtonAction(_ sender: Any) {
        let transition: CATransition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromLeft
        view.window!.layer.add(transition, forKey: nil)
        dismiss(animated: false, completion: nil)
    }

    @IBAction func detailButtonAction(_ sender: Any) {
        if let wdi = wikiDataId {
            let wdiUri = "https://www.wikidata.org/wiki/\(wdi)"
            if let urlDetail = URL(string: wdiUri) {
                UIApplication.shared.open(urlDetail)
            }
        }
    }

    @IBAction func savedButtonAction(_ sender: Any) {
        if savedButton.image == UIImage(named: "unsaved") {
            savedButton.image = UIImage(named: "saved")
            SCArray.name.append(name!)
            SCArray.code.append(code!)
        } else {
            savedButton.image = UIImage(named: "unsaved")
            if let index = SCArray.name.firstIndex(of: name!) {
                SCArray.name.remove(at: index)
                SCArray.code.remove(at: index)
            }
        }
        UserDefaults.standard.removeObject(forKey: "savedCountriesName")
        UserDefaults.standard.removeObject(forKey: "savedCountriesCode")
        UserDefaults.standard.synchronize()
        UserDefaults.standard.set(SCArray.name, forKey: "savedCountriesName")
        UserDefaults.standard.set(SCArray.code, forKey: "savedCountriesCode")
        UserDefaults.standard.synchronize()
    }

    func getCountryDetails(countryCode: String, host: String, key: String, url: String) {
        if countryCode != "error" && countryCode != "" {
            let headers: HTTPHeaders = [
                "x-rapidapi-host": host,
                "x-rapidapi-key": key,
            ]

            AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { details in
                switch details.result {
                case let .success(value):
                    let detailsJson = JSON(value)
                    let dic = detailsJson.dictionary
                    if dic?["data"] != nil {
                        self.wikiDataId = dic?["data"]?["wikiDataId"].stringValue
                        let flagImageUri = dic?["data"]?["flagImageUri"].stringValue
                        if let fiu = flagImageUri {
                            var svgUrlRemote: URL {
                                let path = fiu
                                return URL(string: path)!
                            }
                            let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.countryImageView.frame.width, height: self.countryImageView.frame.height))
                            let request = URLRequest(url: svgUrlRemote)
                            webView.load(request)
                            self.countryImageView.addSubview(webView)
                        }
                    }
                case let .failure(e):
                    print(e)
                }
            }
        }
    }
}
