//
//  PlanCreateViewController.swift
//  Clubs
//
//  Created by o.yuki on 2021/11/23.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess

class PlanCreateViewController: UIViewController {
    var clubId: Int! = 0
    let consts = Constants.shared
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var meetingField: UIDatePicker!
    @IBOutlet weak var dissolutionField: UIDatePicker!
    @IBOutlet weak var placeField: UITextField!
    @IBOutlet weak var remarksField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPlanButton(_ sender: Any) {
        if nameField.text == "" || placeField.text == ""{
            return
        }
        print("meeting\n\(meetingField.date)")
        let keychain = Keychain(service: self.consts.service)
        guard let token = keychain["access_token"] else {return}
        let parameters:Parameters = [
            "name": nameField.text!,
            "meeting_time": format(date: meetingField.date),
            "dissolution_time": format(date: dissolutionField.date),
            "place": placeField.text!,
            "remarks": remarksField.text!
        ]
        let url = URL(string: consts.baseUrl + "/clubs/\(clubId!)/plans")!
        print("PlanCreateVC\ntargetURL\n\(url)")
        let headers: HTTPHeaders = [
            "Content-Type": "applicasion/json",
            "Authorization": "Bearer \(token)"
        ]
        //Alamofireでリクエスト
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value).arrayValue
                print("レスポンス\n\(json)")
                self.dismiss(animated: true, completion: nil)
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    func format(date:Date)->String{
        
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: "ja_JP")
        dateformatter.dateStyle = .medium
        dateformatter.timeStyle = .medium
        let strDate = dateformatter.string(from: date)
        
        return strDate
    }
    
}
