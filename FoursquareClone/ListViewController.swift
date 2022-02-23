//
//  ListViewController.swift
//  FoursquareClone
//
//  Created by Nihad Ismayilov on 17.02.22.
//

import UIKit
import Firebase

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var placeNameArray = [String]()
    var placeIdArray = [String]()
    var selesctedPlaceId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItem.Style.plain, target: self, action: #selector(logoutButton))
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButton))
        
        getData()
        
    }
    
    func getData() {
        
        let firestoreDatabase = Firestore.firestore()
        
        firestoreDatabase.collection("Places").addSnapshotListener { snapshot, error in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                
                if snapshot?.isEmpty != true && snapshot != nil {
                    
                    self.placeNameArray.removeAll(keepingCapacity: false)
                    self.placeIdArray.removeAll(keepingCapacity: false)
                    
                    for document in snapshot!.documents {
                        
                        let documentId = document.documentID
                        self.placeIdArray.append(documentId)
                        if let postedBy = document.get("placeName") as? String {
                            self.placeNameArray.append(postedBy)
                        }
                    }
                }
                self.tableView.reloadData()
                
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = placeNameArray[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetails" {
            let destination = segue.destination as! ListDetailsVC
            destination.chosenPlaceId = selesctedPlaceId
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selesctedPlaceId = placeIdArray[indexPath.row]
        self.performSegue(withIdentifier: "toDetails", sender: nil)
    }
    
    
    
    
    
    
    
    
    
    
    @objc func logoutButton() {
        
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "toViewController", sender: nil)
        } catch {
            print("error")
        }
    }
    @objc func addButton() {
        performSegue(withIdentifier: "toPlaceDetails", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //placeNameArray.remove(at: indexPath.row)
            //placeIdArray.remove(at: indexPath.row)
        }
    }
    
}
