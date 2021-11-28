//
//  RequestViewController.swift
//  Clubs
//
//  Created by o.yuki on 2021/11/20.
//

import UIKit
import AuthenticationServices
import Alamofire
import SwiftyJSON
import KeychainAccess

class RequestViewController: UIViewController {
    let consts = Constants.shared
    var token = ""
    
    @IBOutlet weak var clubIdField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var nickNameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func pressRequestButton(_ sender: Any) {
        requestClub()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func requestClub() {
        let keychain = Keychain(service: self.consts.service)
        
        guard let token = keychain["access_token"] else {return}
        
        let url = URL(string: consts.baseUrl + "/request")!
        //        guard let code = code else { return }
        let headers: HTTPHeaders = [
            //            "Content-Type": "application/json",
            //            "ACCEPT": "application/json",
            .authorization(bearerToken: token)
        ]
        let parameters: Parameters = [
            "unique_name": clubIdField.text!,
            "password": passwordField.text!,
            "name": nickNameField.text!
        ]
        
        //Alamofireでリクエスト
        AF.request(url, method: .post, parameters: parameters, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                self.dismiss(animated: true, completion: nil)
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
}
