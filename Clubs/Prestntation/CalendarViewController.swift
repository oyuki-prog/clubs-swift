//
//  CalendarViewController.swift
//  Clubs
//
//  Created by o.yuki on 2021/11/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess

//MARK:- Protocol
protocol ViewLogic {
    var numberOfWeeks: Int { get set }
    var daysArray: [String]! { get set }
}

class CalendarViewController: UIViewController , ViewLogic {
    
    //MARK: Properties
    var numberOfWeeks: Int = 0
    var daysArray: [String]!
    
    let consts = Constants.shared
    var thisMonthPlans: [Plan] = []
    var todayPlan:[Plan] = []
    var threads:[Thread] = []
    var planDetail:[SwiftyJSON.JSON] = []
    let clearsSelectionOnViewWillAppear: Bool = true
    
    private var requestForCalendar: RequestForCalendar?
    
    var clubName: String!
    var clubId: Int!
    private let date = DateItems.ThisMonth.Request()
    private let daysPerWeek = 7
    private var thisYear: Int = 0
    private var thisMonth: Int = 0
    private var today: Int = 0
    private var isToday = true
    var month: Int = 0
    var year: Int = 0
    private let dayOfWeekLabel = ["日", "月", "火", "水", "木", "金", "土"]
    private var monthCounter = 0
    
    //MARK: UI Parts
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var clubNameLabel: UILabel!
    
    @IBAction func prevButton(_ sender: Any) {
        prevMonth()
    }
    @IBAction func nextButton(_ sender: Any) {
        nextMonth()
    }
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Initialize
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        dependencyInjection()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        dependencyInjection()
    }
    
    //MARK: Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view.
        clubNameLabel.text = clubName
        configure()
        settingLabel()
        getToday()
        print("CalendarVC\n今月の予定\n\(thisMonthPlans)\n")
    }
        
    //MARK: Setting
    private func dependencyInjection() {
        let viewController = self
        let calendarController = CalendarController()
        let calendarPresenter = CalendarPresenter()
        let calendarUseCase = CalendarUseCase()
        viewController.requestForCalendar = calendarController
        calendarController.calendarLogic = calendarUseCase
        calendarUseCase.responseForCalendar = calendarPresenter
        calendarPresenter.viewLogic = viewController
    }
    
    private func configure() {
        collectionView.dataSource = self
        collectionView.delegate = self
        requestForCalendar?.requestNumberOfWeeks(request: date)
        requestForCalendar?.requestDateManager(request: date)
    }
    
    private func settingLabel() {
        monthLabel.text = "\(String(date.year))年\(String(date.month))月"
    }
    
    private func getToday() {
        thisYear = date.year
        thisMonth = date.month
        today = date.day
    }
    
    //その月のプラン情報全て取得
    func getPlans() {
        let keychain = Keychain(service: self.consts.service)
        guard let token = keychain["access_token"] else {return}
        let url = URL(string: consts.baseUrl + "/clubs/\(clubId!)/\(year)/\(month)")!
        print("CalendarVC\ntargetURL\n\(url)\n")
        let headers: HTTPHeaders = [
            "Content-Type": "applicasion/json",
            "Authorization": "Bearer \(token)"
        ]
        
        //Alamofireでリクエスト
        AF.request(url, method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                self.thisMonthPlans = []
                let json = JSON(value).arrayValue
                for data in json {
                    self.thisMonthPlans.append(Plan(id: data["plan"]["id"].int!,
                                                    name: data["plan"]["name"].string!,
                                                    meeting_time: data["plan"]["meeting_time"].string!,
                                                    dissolution_time: data["plan"]["dissolution_time"].string!,
                                                    place: data["plan"]["place"].string,
                                                    remarks: data["plan"]["remarks"].string,
                                                    can:data["can"].bool!))
                }
                print("CalendarVC\n今月の予定\n\(self.thisMonthPlans)\n")
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    func getThreads(planId: Int) {
        let keychain = Keychain(service: self.consts.service)
        guard let token = keychain["access_token"] else {return}
        let url = URL(string: consts.baseUrl + "/clubs/\(clubId!)/plans/\(planId)")!
        print("CalendarVC\ntargetURL\n\(url)\n")
        let headers: HTTPHeaders = [
            "Content-Type": "applicasion/json",
            "Authorization": "Bearer \(token)"
        ]
        
        //Alamofireでリクエスト
        AF.request(url, method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                self.planDetail = []
                let json = JSON(value).arrayValue
                self.planDetail = json
                
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    @IBAction func addPlanButton(_ sender: Any) {
        let planCreateVC = self.storyboard?.instantiateViewController(withIdentifier: "PlanCreateVC") as? PlanCreateViewController
        if let planCreateVC = planCreateVC{
            planCreateVC.clubId = self.clubId
            self.present(planCreateVC, animated: true, completion: nil)
        }

    }
    
}

//MARK:- Setting Button Items
extension CalendarViewController {
    
    private func nextMonth() {
        monthCounter += 1
        commonSettingMoveMonth()
    }
    
    private func prevMonth() {
        monthCounter -= 1
        commonSettingMoveMonth()
    }
    
    private func commonSettingMoveMonth() {
        daysArray = nil
        let moveDate = DateItems.MoveMonth.Request(monthCounter)
        requestForCalendar?.requestNumberOfWeeks(request: moveDate)
        requestForCalendar?.requestDateManager(request: moveDate)
        
        isToday = thisYear == moveDate.year && thisMonth == moveDate.month ? true : false
        month = moveDate.month
        year = moveDate.year
        getPlans()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.monthLabel.text = "\(String(moveDate.year))年\(String(moveDate.month))月"
            self.collectionView.reloadData()
        }
    }
}

//MARK:- UICollectionViewDataSource
extension CalendarViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 7 : (numberOfWeeks * daysPerWeek)
    }
    
    //セルを作る際の処理
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let label = cell.contentView.viewWithTag(1) as! UILabel
        label.backgroundColor = .clear
        dayOfWeekColor(label, indexPath.row, daysPerWeek)
        showDate(indexPath.section, indexPath.row, cell, label)
        
        self.todayPlan = []
        self.todayPlan = self.thisMonthPlans.filter{ label.text == self.dateOnly(meeting_time: $0.meeting_time) }
        if todayPlan.count != 0 {
            label.backgroundColor = .green
            if todayPlan[0].can == false {
                label.backgroundColor = .gray
            }
        }
        
        return cell
    }
    
    private func dayOfWeekColor(_ label: UILabel, _ row: Int, _ daysPerWeek: Int) {
        switch row % daysPerWeek {
        case 0: label.textColor = .red
        case 6: label.textColor = .blue
        default: label.textColor = .black
        }
    }
    
    private func showDate(_ section: Int, _ row: Int, _ cell: UICollectionViewCell, _ label: UILabel) {
        switch section {
        case 0:
            label.text = dayOfWeekLabel[row]
            cell.selectedBackgroundView = nil
        default:
            label.text = daysArray[row]
            let selectedView = UIView()
            selectedView.backgroundColor = .mercury()
            cell.selectedBackgroundView = selectedView
            markToday(label)
        }
    }
    
    private func markToday(_ label: UILabel) {
        if isToday, today.description == label.text {
            label.backgroundColor = .myLightRed()
        }
    }
    
    func dateOnly(meeting_time: String) -> String{
        let str = meeting_time
        let start = str.index(str.startIndex, offsetBy: 8)
        let end = str.index(str.endIndex, offsetBy: -10)
        if String([str[start]]) == "0" {
            let start = str.index(str.startIndex, offsetBy: 9)
            return(String(str[start...end]))
        }
        return(String(str[start...end]))
    }
    
}

//MARK:- UICollectionViewDelegateFlowLayout
extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let weekWidth = Int(collectionView.frame.width) / daysPerWeek
        let weekHeight = weekWidth
        let dayWidth = weekWidth
        let dayHeight = (Int(collectionView.frame.height) - weekHeight) / numberOfWeeks
        return indexPath.section == 0 ? CGSize(width: weekWidth, height: weekHeight) : CGSize(width: dayWidth, height: dayHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let surplus = Int(collectionView.frame.width) % daysPerWeek
        let margin = CGFloat(surplus)/2.0
        return UIEdgeInsets(top: 0.0, left: margin, bottom: 1.5, right: margin)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //セルを選択された際の処理
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        let label = cell?.contentView.viewWithTag(1) as! UILabel
        
        self.todayPlan = []
        self.todayPlan = self.thisMonthPlans.filter { label.text! == self.dateOnly(meeting_time: $0.meeting_time) }
        if todayPlan.count != 0 {
            if todayPlan[0].can == true {
                print("planId\n\(todayPlan[0].id)")
                getThreads(planId: todayPlan[0].id)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    // 0.5秒後に実行したい処理
                    let plansVC = self.storyboard?.instantiateViewController(withIdentifier: "PlansVC") as? PlansViewController
                    if let plansVC = plansVC{
                        plansVC.detail = self.planDetail
                        plansVC.clubId = self.clubId
                        plansVC.planId = self.todayPlan[0].id
                        self.present(plansVC, animated: true, completion: nil)
                    }
                }
            }
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
