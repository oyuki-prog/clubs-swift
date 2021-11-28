//
//  ViewController.swift
//  Clubs
//
//  Created by o.yuki on 2021/11/20.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess

class ViewController: UIViewController {
    let consts = Constants.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let keychain = Keychain(service: self.consts.service)
        if keychain["access_token"] != nil {
            print(keychain)
            //            keychain["access_token"] = nil //keychainに保存されたtokenを削除
            isLogin() //loginトークンがあればクラブ一覧に遷移
        }
        
        // Do any additional setup after loading the view.
    }


    func isLogin() {
       let clubsViewContorller = self.storyboard?.instantiateViewController(withIdentifier: "ClubsViewController") as! UIViewController
        clubsViewContorller.modalPresentationStyle = .fullScreen
       present(clubsViewContorller, animated: true, completion: nil)
    }
}

