//
//  HomeVC.swift
//  InstaPost
//
//  Created by Vaibhav Khatri on 24/04/24.
//

import UIKit
import FirebaseFirestore

class HomeVC: UIViewController {
    
    @IBOutlet weak var tableViewPostLsit: UITableView!
    
    let db = Firestore.firestore()
    var listener: ListenerRegistration?
    var arrayOfQuerySnapshot : [QueryDocumentSnapshot] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewPostLsit.register(UINib(nibName: "PostListTableViewCell", bundle: nil), forCellReuseIdentifier: "PostListTableViewCell")
        startListeningForNewDocuments()
        self.fetchPosts()
    }
    
}

//MARK: - TableView DataSource
extension HomeVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.arrayOfQuerySnapshot.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostListTableViewCell", for: indexPath) as! PostListTableViewCell
        cell.labelTitle.text = self.arrayOfQuerySnapshot[indexPath.row].data()["userId"] as? String
        cell.labelDescription.text = self.arrayOfQuerySnapshot[indexPath.row].data()["postDescription"] as? String
        
        if let timestamp = self.arrayOfQuerySnapshot[indexPath.row].data()["postCreationDate"] as? Timestamp {
            // Convert Timestamp to Date
            let date = timestamp.dateValue()
            
            // Format Date to string
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = dateFormatter.string(from: date)
            
            cell.labelCreatinDate.text = timeAgoString(from: dateString)
        }
        
        cell.arrayOfImages = self.arrayOfQuerySnapshot[indexPath.row].data()["imageUrls"] as? [String] ?? []
        DispatchQueue.main.async {
            cell.collectionViewImage.reloadData()
        }
        return cell
    }
}

//MARK: - Fetch the Posts for the first time and add the listner for real time update
extension HomeVC{
    func fetchPosts(){
        db.collection("posts").getDocuments { querySnapshot, error in
            if error != nil{
                
                return
            }
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
    
    func startListeningForNewDocuments() {
        let usersCollection = db.collection("posts")
        
        listener = usersCollection.addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            
            self.arrayOfQuerySnapshot = documents
            DispatchQueue.main.async {
                self.tableViewPostLsit.reloadData()
            }
        }
    }
}
