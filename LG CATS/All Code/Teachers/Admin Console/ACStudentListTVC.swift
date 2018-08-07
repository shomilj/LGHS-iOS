//
//  ACStudentListTVC.swift
//  LG CATS
//
//  Created by Shomil Jain on 7/28/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import Firebase

class ACStudentListTVC: UITableViewController, UISearchBarDelegate {

    var ref: DatabaseReference!
    var students = [Student]()
    
    var filteredStudents = [Student]()
    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.backgroundColor = UIColor.white
        searchController.searchBar.placeholder = "Search"
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        definesPresentationContext = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }
    
    @IBAction func unwindToACStudentList(sender: UIStoryboardSegue) {}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ref = Database.database().reference()
            .child(Keys.Database.version)
            .child(Keys.Database.appData)
            .child(Keys.Database.studentRoster)
        
        ref.observe(.value) { (snapshot) in
            
            guard let dict = snapshot.value as? [String: Any] else {
                return;
            }
            guard let list = StudentList.parseStudents(fromDict: dict) else {
                Log.w("Unable to parse students, or none in list!")
                return;
            }
            
            self.students = list
            self.students.sort(by: { (s1, s2) -> Bool in
                return s1.firstName < s2.firstName
            })
            self.tableView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ref.removeAllObservers()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredStudents.count
        }
        
        return students.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let student: Student
        if isFiltering() {
            student = filteredStudents[indexPath.row]
        } else {
            student = students[indexPath.row]
        }
        cell?.textLabel?.text = student.fullName
        cell?.detailTextLabel?.text = "\(student.id!) • \(student.email!) • Class of \(student.year!)"
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.tableView.beginUpdates()
            if isFiltering() {
                let student = filteredStudents.remove(at: indexPath.row)
                if let index = students.index(where: {$0 === student}) {
                    students.remove(at: index)
                }
                student.deleteSelf()
            } else {
                students.remove(at: indexPath.row)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.endUpdates()
        }
    }
    
    @objc func addTapped() {
        self.performSegue(withIdentifier: "add", sender: self)
    }
    
}

extension ACStudentListTVC: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredStudents = students.filter({( student : Student) -> Bool in
            return student.fullName.lowercased().contains(searchText.lowercased()) || student.email.lowercased().contains(searchText.lowercased()) || student.id.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

}

