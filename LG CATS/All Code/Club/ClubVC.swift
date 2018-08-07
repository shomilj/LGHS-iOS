//
//  ClubVC.swift
//  Falcon
//
//  Created by Shomil Jain on 7/22/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import Firebase

class ClubVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableData: [Club] = []
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 66.0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadingOverlay.shared.showOverlay(self.view)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        Database.database().reference().child(Keys.Database.version).child(Keys.Database.appData).child(Keys.Database.clubs).observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String: [String: String]] else {
                Log.e("Failed to download clubs! Check structure in database.")
                self.showError(message: "The club list is not available at this time. Please try again later.", title: "Error", completion: {
                    LoadingOverlay.shared.hideOverlayView()
                    self.dismiss(animated: true, completion: nil)
                })
                return;
            }
            var clubs = Club.parseClubs(fromDict: dict)
            if clubs.count == 0 {
                Log.e("Zero clubs! Check structure in database.")
                self.showError(message: "The club list is not available at this time. Please try again later.", title: "Error", completion: {
                    LoadingOverlay.shared.hideOverlayView()
                    self.dismiss(animated: true, completion: nil)
                })
                return;
            }
            LoadingOverlay.shared.hideOverlayView()
            clubs.sort { (c1, c2) -> Bool in
                return c1.name < c2.name
            }
            self.tableData = clubs
            self.tableView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ClubCell
        cell.titleLabel.text = tableData[indexPath.row].name
        cell.detailLabel.text = tableData[indexPath.row].time + " - " + tableData[indexPath.row].location
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier, id == "next", let nextView = segue.destination as? ClubDetailVC, let path = self.tableView.indexPathForSelectedRow {
            nextView.club = self.tableData[path.row]
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }

}
