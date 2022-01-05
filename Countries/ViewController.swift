//
//  ViewController.swift
//  Countries
//
//  Created by Umut Can Alparslan on 3.01.2022.
//

import Alamofire
import Foundation
import SwiftyJSON
import UIKit

class ViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    public static var host = "wft-geo-db.p.rapidapi.com"
    public static var key = "YOUR_RAPIDAPI_KEY"
    public static var uri = "https://wft-geo-db.p.rapidapi.com/v1/geo/countries"

    var name = [String]()
    var code = [String]()
    var savedCountries = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemOrange

            let tabBarItemAppearance = UITabBarItemAppearance()
            tabBarItemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            tabBarItemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            tabBarItemAppearance.normal.iconColor = .black
            tabBarItemAppearance.selected.iconColor = .white
            appearance.stackedLayoutAppearance = tabBarItemAppearance

            tabBarController?.tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBarController?.tabBar.scrollEdgeAppearance = appearance
        }


        getCountries()
    }

    override func viewWillAppear(_ animated: Bool) {
        savedCountries.removeAll(keepingCapacity: false)
        savedCountries = UserDefaults.standard.stringArray(forKey: "savedCountriesName") ?? [String]()
        tableView.reloadData()
    }

    func getCountries() {
        let headers: HTTPHeaders = [
            "x-rapidapi-host": ViewController.host,
            "x-rapidapi-key": ViewController.key,
        ]

        let url = "\(ViewController.uri)?offset=0&limit=10"
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { countries in
            switch countries.result {
            case let .success(value):
                self.name.removeAll(keepingCapacity: false)
                self.code.removeAll(keepingCapacity: false)
                let countriesJson = JSON(value)
                if countriesJson.dictionary?["data"] != nil {
                    let arr = JSON(countriesJson.dictionary?["data"]! as Any)
                    for country in arr.array! {
                        self.name.append(country["name"].stringValue)
                        self.code.append(country["code"].stringValue)
                    }
                }
                self.tableView.reloadData()
            case let .failure(e):
                print(e)
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return name.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountriesCell", for: indexPath) as! CountriesCell
        cellViewUI(cellView: cell.countryView, cellName: name[indexPath.row], cellLabel: cell.countryName, cellButton: cell.savedButton)

        if savedCountries.contains(name[indexPath.row]) {
            cell.savedButton.setImage(UIImage(named: "saved"), for: .normal)
        } else {
            cell.savedButton.setImage(UIImage(named: "unsaved"), for: .normal)
        }

        cell.actionBlock = {
            if cell.savedButton.currentImage == UIImage(named: "unsaved") {
                cell.savedButton.setImage(UIImage(named: "saved"), for: .normal)
                SCArray.name.append(self.name[indexPath.row])
                SCArray.code.append(self.code[indexPath.row])
            } else {
                cell.savedButton.setImage(UIImage(named: "unsaved"), for: .normal)
                if let index = SCArray.name.firstIndex(of: self.name[indexPath.row]) {
                    SCArray.name.remove(at: index)
                    SCArray.code.remove(at: index)
                }
            }
            SCArray.userDefaultsSettings()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyBoard.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
        detailVC.code = code[indexPath.row]
        detailVC.name = name[indexPath.row]
        let navController = UINavigationController(rootViewController: detailVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }

    func cellViewUI(cellView: UIView, cellName: String, cellLabel: UILabel, cellButton: UIButton) {
        cellLabel.text = cellName
        cellView.layer.borderColor = UIColor.black.cgColor
        cellView.layer.borderWidth = 2.0
        cellView.layer.cornerRadius = 10.0
        cellView.layer.masksToBounds = false
        cellView.clipsToBounds = true
        cellButton.setTitle("", for: .normal)
    }
}
