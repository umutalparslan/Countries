//
//  SavedCountriesVC.swift
//  Countries
//
//  Created by Umut Can Alparslan on 5.01.2022.
//

import UIKit

class SavedCountriesVC: UIViewController {
    @IBOutlet var tableView: UITableView!

    var name = [String]()
    var code = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        name.removeAll(keepingCapacity: false)
        code.removeAll(keepingCapacity: false)
        name = UserDefaults.standard.stringArray(forKey: "savedCountriesName") ?? [String]()
        code = UserDefaults.standard.stringArray(forKey: "savedCountriesCode") ?? [String]()
        tableView.reloadData()
    }
}

extension SavedCountriesVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SCArray.name.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedCountriesCell", for: indexPath) as! SavedCountriesCell
        cell.countryName.text = name[indexPath.row]
        cell.countryView.layer.borderColor = UIColor.black.cgColor
        cell.countryView.layer.borderWidth = 2.0
        cell.countryView.layer.cornerRadius = 10.0
        cell.countryView.layer.masksToBounds = false
        cell.countryView.clipsToBounds = true
        cell.saveButton.setImage(UIImage(named: "saved"), for: .normal)
        cell.saveButton.tag = indexPath.row
        cell.saveButton.setTitle("", for: .normal)

        cell.actionBlock = {
            cell.saveButton.setImage(UIImage(named: "unsaved"), for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.removeUnsaved(section: indexPath.section, row: cell.saveButton.tag)
            }
            if let index = SCArray.name.firstIndex(of: self.name[indexPath.row]) {
                SCArray.name.remove(at: index)
                SCArray.code.remove(at: index)
                self.name.remove(at: index)
                self.code.remove(at: index)
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

    func removeUnsaved(section: Int, row: Int) {
        tableView.beginUpdates()
        tableView.numberOfRows(inSection: section)
        tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .fade)
        tableView.endUpdates()
        tableView.reloadData()
    }
}
