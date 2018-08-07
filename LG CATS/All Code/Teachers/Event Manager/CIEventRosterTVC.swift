//
//  CIEventRosterTVC.swift
//  Black Panther
//
//  Created by Shomil Jain on 5/22/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit

class CIEventRosterTVC: UITableViewController, UISearchBarDelegate {

    var allStudents = [CIEventStudent]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var filterLabel: UIBarButtonItem!
    
    var tableData = [CIEventStudent]()
    var filteredData = [CIEventStudent]()
    
    var currentView: viewChoices = .all
    
    public enum viewChoices: String {
        case all
        case checkedIn
        case notCheckedIn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.tintColor = UIColor.primary
        self.navigationController?.setToolbarHidden(false, animated: true)
        self.navigationController?.toolbar.barTintColor = UIColor.primary
        self.navigationController?.toolbar.tintColor = UIColor.black
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: Notification.Name(Keys.Notifications.eventObserverUpdate), object: nil)
        searchBar.delegate = self
        searchBar.spellCheckingType = .no
        filteredData = tableData
        updateUI()
        self.filteredData = self.tableData
        self.tableView.reloadData()
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        filteredData = searchText.isEmpty ? tableData : tableData.filter({(stu: CIEventStudent) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return stu.name.range(of: searchText, options: .caseInsensitive) != nil
        })
        
        tableView.reloadData()
    }
    
    @IBAction func exportTapped(_ sender: Any) {
        LoadingOverlay.shared.showOverlay(self.view)
        
        let fileName = "Sign-In Sheet for \(CIEvent.shared.getName()).csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
    
        var text = "Name,Id,Checked In?\n"
        let list = CIEvent.shared.getStudents().sorted { $0.checkedIn && !$1.checkedIn }
        
        for student in list {
            var checkedIn = "No"
            if student.checkedIn {
                checkedIn = "Yes"
            }
            text.append("\(student.name),\(student.id),\(checkedIn)\n")
        }
        print(text)
        do {
            try text.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
        LoadingOverlay.shared.hideOverlayView()
        let vc = UIActivityViewController(activityItems: [path!], applicationActivities: [])
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func searchTapped(_ sender: Any) {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        } else {
            searchBar.becomeFirstResponder()
        }
    }
    
    @IBAction func filterTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Filter Students", message: "What would you like to see?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "All Students", style: .default , handler: { (UIAlertAction) in
            self.currentView = viewChoices.all
            self.updateUI()
        }))
        
        alert.addAction(UIAlertAction(title: "Checked In Students", style: .default , handler: { (UIAlertAction) in
            self.currentView = viewChoices.checkedIn
            self.updateUI()
        }))
        
        alert.addAction(UIAlertAction(title: "Students Not Checked In", style: .default , handler: { (UIAlertAction) in
            self.currentView = viewChoices.notCheckedIn
            self.updateUI()
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func updateUI() {
        
        if currentView == viewChoices.all {
            self.tableData = CIEvent.shared.getStudents().sorted(by: { $0.name < $1.name})
        } else if currentView == viewChoices.checkedIn {
            var checkedIn = [CIEventStudent]()
            for stu in CIEvent.shared.getStudents() {
                if stu.checkedIn {
                    checkedIn.append(stu)
                }
            }
            checkedIn.sort(by: { $0.name < $1.name })
            self.tableData = checkedIn
        } else if currentView == viewChoices.notCheckedIn {
            var notCheckedIn = [CIEventStudent]()
            for stu in CIEvent.shared.getStudents() {
                if !stu.checkedIn {
                    notCheckedIn.append(stu)
                }
            }
            notCheckedIn.sort(by: { $0.name < $1.name })
            self.tableData = notCheckedIn
        }
        
        if searchBar.isFirstResponder {
            // User is typing...do strategic update!
            var dict = [String: CIEventStudent]()
            for stu in tableData {
                dict[stu.id] = stu
            }
            for (index, stu) in filteredData.enumerated() {
                filteredData[index] = dict[stu.id] ?? stu
            }
        } else {
            // User is not typing! Update all!
            self.filteredData = self.tableData
        }
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let stu = filteredData[indexPath.row]
        cell.textLabel!.text = stu.name
        if stu.checkedIn {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let stu = filteredData[indexPath.row]
        if stu.checkedIn {
            CIEvent.shared.updateStatus(forStudent: stu.id, value: false)
        } else {
            CIEvent.shared.updateStatus(forStudent: stu.id, value: true)
        }
    }

}
