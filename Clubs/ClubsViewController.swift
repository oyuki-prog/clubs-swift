//
//  ClubsViewController.swift
//  Clubs
//
//  Created by o.yuki on 2021/11/20.
//

import UIKit
import AuthenticationServices
import Alamofire
import SwiftyJSON
import KeychainAccess

class ClubsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var clubTableView: UITableView!
    
    let consts = Constants.shared
    var token = ""
    var clubs: [Club] = []
    var plans: [Plan] = []
    private let date = DateItems.ThisMonth.Request()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clubTableView.delegate = self
        clubTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getClubs()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return clubs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClubCell", for: indexPath)
        
        let clubNameLabel = cell.viewWithTag(1) as! UILabel
        clubNameLabel.text = clubs[indexPath.row].name
        
        let roleNameLabel = cell.viewWithTag(2) as! UILabel
        roleNameLabel.text = clubs[indexPath.row].rolename
        if roleNameLabel.text == "申請中" {
            roleNameLabel.backgroundColor = .gray
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return self.view.frame.height * 1 / 8
    }
    
    
    //セルが選択されたときの処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let label = cell?.viewWithTag(2) as! UILabel
        if label.text == "申請中" {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        getPlans(clubId: Int(clubs[indexPath.row].id))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // 0.5秒後に実行したい処理
            let calendarVC = self.storyboard?.instantiateViewController(withIdentifier: "calendarView") as? CalendarViewController
            if let calendarVC = calendarVC{
                calendarVC.thisMonthPlans = self.plans
                calendarVC.clubName = self.clubs[indexPath.row].name
                calendarVC.clubId = self.clubs[indexPath.row].id
                
                self.present(calendarVC, animated: true, completion: nil)
            }
        }
    }
    
    func getClubs() {
        let keychain = Keychain(service: self.consts.service)
        
        guard let token = keychain["access_token"] else {return}
        
        let url = URL(string: consts.baseUrl + "/clubs")!
        let headers: HTTPHeaders = [
            "Content-Type": "applicasion/json",
            "Authorization": "Bearer \(token)"
        ]
        
        //Alamofireでリクエスト
        AF.request(url, method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                self.clubs = []
                let json = JSON(value).arrayValue
                
                for data in json {
                    self.clubs.append(Club(id: data["club"]["id"].int!,
                                           name: data["club"]["name"].string!,
                                           unique_name: data["club"]["unique_name"].string!,
                                           rolename: data["role"]["role_name"].string!))
                }
                self.clubTableView.reloadData()
                print("ClubVC\n参加クラブ一覧\n\(self.clubs)\n")
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    func getPlans(clubId: Int!) {
        let keychain = Keychain(service: self.consts.service)
        let thisYear: Int! = date.year
        let thisMonth: Int! = date.month
        guard let token = keychain["access_token"] else {return}
        let url = URL(string: consts.baseUrl + "/clubs/\(clubId!)/\(thisYear!)/\(thisMonth!)")!
        print("ClubVC\ntargetURL\n\(url)\n")
        let headers: HTTPHeaders = [
            "Content-Type": "applicasion/json",
            "Authorization": "Bearer \(token)"
        ]
        
        //Alamofireでリクエスト
        AF.request(url, method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                self.plans = []
                let json = JSON(value).arrayValue
                for data in json {
                    self.plans.append(Plan(id: data["plan"]["id"].int!,
                                           name: data["plan"]["name"].string!,
                                           meeting_time: data["plan"]["meeting_time"].string!,
                                           dissolution_time: data["plan"]["dissolution_time"].string!,
                                           place: data["plan"]["place"].string,
                                           remarks: data["plan"]["remarks"].string,
                                           can: data["can"].bool!))
                }
                print("ClubVC\n今月の予定\n\(self.plans)\n")
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
}


