//
//  TableViewController.swift
//  Clubs
//
//  Created by o.yuki on 2021/11/20.
//

import UIKit
import AuthenticationServices
import Alamofire
import SwiftyJSON
import KeychainAccess

class ClubViewController: UIViewController {
    @IBOutlet var clubTableView: UITableView!
    
    let consts = Constants.shared
    var token = ""
    var clubs: [Club] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getClubs()
   
//        clubTableView.dataSource = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return clubs.count
    }
    
    func getClubs() {
        let keychain = Keychain(service: self.consts.service)
        
        guard let token = keychain["access_token"] else {return}
        
        let url = URL(string: consts.baseUrl + "/clubs")!
        //        guard let code = code else { return }
        let headers: HTTPHeaders = [
//            "Content-Type": "application/json",
//            "ACCEPT": "application/json",
            .authorization(bearerToken: token)
        ]
        
        //Alamofireでリクエスト
        AF.request(url, method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                self.clubs = []
                let json = JSON(value).arrayValue
                
                for data in json {
                    self.clubs.append(Club(name: data["club"]["name"].string!, unique_name: data["club"]["unique_name"].string!, rolename: data["role"]["role_name"].string!))
                }
//                let token: String? = json["token"].string
//                guard let accessToken = token else { return }
                print(self.clubs)
                self.clubTableView.reloadData()
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }

     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "ClubCell", for: indexPath)
         var content = cell.defaultContentConfiguration()
         content.text = clubs[indexPath.row].name
         cell.contentConfiguration = content
         return cell
     }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
