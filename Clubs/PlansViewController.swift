//
//  PlansViewController.swift
//  Clubs
//
//  Created by o.yuki on 2021/11/22.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess

class PlansViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var meetingTimeLabel: UILabel!
    @IBOutlet weak var dissolutionTimeLabel: UILabel!
    @IBOutlet weak var remarks: UILabel!
    @IBOutlet weak var remarksLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    var detail:[SwiftyJSON.JSON] = []
    var clubId:Int! = 0
    var planId:Int! = 0
    var threads:[Thread] = []
    let consts = Constants.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        print("PlansVC\nプラン詳細\n\(detail[0]["plan"])")
        for data in detail[0]["threads"] {
            print("プリント\n\(data.1["user"])")
            self.threads.append(Thread(id: data.1["thread"]["id"].int!,
                                       planId: data.1["thread"]["plan_id"].int!,
                                       body: data.1["thread"]["body"].string,
                                       file: data.1["thread"]["file"].string,
                                       user: data.1["user"]["name"].string!))
        }
        titleLabel.text = detail[0]["plan"]["name"].string!
        
        let date =  detail[0]["plan"]["meeting_time"].string!


        let df = DateFormatter()

        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        print(df.string(for: date))
        // 2019-10-19 17:01:09

        dayLabel.text = df.string(for: date)
        
        meetingTimeLabel.text = detail[0]["plan"]["meeting_time"].string!
        dissolutionTimeLabel.text = detail[0]["plan"]["dissolution_time"].string!
        placeLabel.text = detail[0]["plan"]["place"].string!
        remarksLabel.text = detail[0]["plan"]["remarks"].string!
    }
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButton(_ sender: Any) {
        if messageTextField.text == "" {
            return
        }
        let keychain = Keychain(service: self.consts.service)
        guard let token = keychain["access_token"] else {return}
        let parameters:Parameters = [
            "body": messageTextField.text
        ]
        let url = URL(string: consts.baseUrl + "/clubs/\(clubId!)/plans/\(planId!)/threads")!
        print("CalendarVC\ntargetURL\n\(url)\n")
        let headers: HTTPHeaders = [
            "Content-Type": "applicasion/json",
            "Authorization": "Bearer \(token)"
        ]
        //Alamofireでリクエスト
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value).arrayValue
                print("スレッド\n\(json)")
                self.threads.append(Thread(id: json[0]["thread"]["id"].int!,
                                               planId: json[0]["thread"]["plan_id"].int!,
                                           body: json[0]["thread"]["body"].string,
                                               file: json[0]["thread"]["file"].string,
                                               user: json[0]["user"]["name"].string!))
                print("CalendarVC\nthreads\n\(self.threads)")
                self.tableView.reloadData()
                self.messageTextField.text! = ""
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
}

extension PlansViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return threads.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "threadCell", for: indexPath)
        let nameLabel = cell.contentView.viewWithTag(1) as! UILabel
        let bodyLabel = cell.contentView.viewWithTag(2) as! UILabel
        nameLabel.text = threads[indexPath.row].user
        bodyLabel.text = threads[indexPath.row].body
        return cell
    }
    
    
}

