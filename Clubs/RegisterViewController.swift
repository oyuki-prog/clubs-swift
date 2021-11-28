//
//  RegisterViewController.swift
//  Clubs
//
//  Created by o.yuki on 2021/11/20.
//

import UIKit
import AuthenticationServices
import Alamofire
import SwiftyJSON
import KeychainAccess

class RegisterViewController: UIViewController {
    let consts = Constants.shared
    var token = ""
    var session: ASWebAuthenticationSession?

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
                tapGR.cancelsTouchesInView = false
                self.view.addGestureRecognizer(tapGR)
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissKeyboard() {
            self.view.endEditing(true)
        }

    @IBAction func pressRegisterButton(_ sender: Any) {
        self.register()
        transitionToClubsView()
    }
    
    func register() {
        let url = URL(string: consts.baseUrl + "/register")!
//        guard let code = code else { return }
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "ACCEPT": "application/json"
        ]
        let parameters: Parameters = [
            "name": nameField.text,
            "email": emailField.text,
            "password": passwordField.text
//            "code": code
        ]
//        print("CODE: \n\(code)")
        //Alamofireでリクエスト
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let token: String? = json["token"].string
                guard let accessToken = token else { return }
                self.token = accessToken
                let keychain = Keychain(service: self.consts.service)
                keychain["access_token"] = accessToken
                print(json)
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    func transitionToClubsView() {
       let clubsViewContorller = self.storyboard?.instantiateViewController(withIdentifier: "ClubsViewController") as! UIViewController
        clubsViewContorller.modalPresentationStyle = .fullScreen
       present(clubsViewContorller, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
