//
//  ScheduleMeetingViewController.swift
//  Drift-SDK
//
//  Created by Eoin O'Connell on 05/02/2018.
//  Copyright © 2018 Drift. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol ScheduleMeetingViewControllerDelegate: class {
    func didDismissScheduleVC()
}

class ScheduleMeetingViewController: UIViewController {

    enum ScheduleMode {
        case day
        case time(date: Date)
        case confirm(date: Date)
        
    }
    
    @IBOutlet var scheduleTableView: UITableView!
    @IBOutlet var containerView: UIView!
    
    @IBOutlet var confirmationView: UIView!
    
    @IBOutlet var confirmationTimeLabel: UILabel!
    @IBOutlet var confirmationDateLabel: UILabel!
    @IBOutlet var confirmationTimeZoneLabel: UILabel!
    @IBOutlet var scheduleButton: UIButton!
    
    var scheduleMode: ScheduleMode = .day
    var userAvailability: UserAvailability?
    
    var userId: Int!
    weak var delegate: ScheduleMeetingViewControllerDelegate?
    
    var days: [Date] = []
    var times: [Date] = []
    
    convenience init(userId: Int, delegate: ScheduleMeetingViewControllerDelegate) {
        self.init(nibName: "ScheduleMeetingViewController", bundle: Bundle(for: ScheduleMeetingViewController.classForCoder()))
        self.userId = userId
        self.delegate = delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
//        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didDismissScheduleVC)))
        
        
        containerView.layer.cornerRadius = 5
        containerView.clipsToBounds = true
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        scheduleTableView.tableFooterView = UIView()
        
        updateForUserId(userId: userId)
    }
    
    @objc func didDismissScheduleVC(){
        delegate?.didDismissScheduleVC()
    }
    
    func updateForUserId(userId: Int) {
        self.userId = userId
        SVProgressHUD.show()
        DriftAPIManager.getUserAvailability(userId) { [weak self] (result) in
            SVProgressHUD.dismiss()
            switch result {
            case .success(let userAvailability):
                self?.userAvailability = userAvailability
                self?.updateForMode(userAvailability: userAvailability)
            case .failure(_):
                self?.showAPIError()
            }
        }
    }
    
    @IBAction func schedulePressed() {
        
    }
    
    func showAPIError(){
        let alert = UIAlertController(title: "Error", message: "Failed to get calendar information", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    func updateForMode(userAvailability: UserAvailability){
     
        switch scheduleMode {
        case .day:
            days = userAvailability.slotsForDays()
            scheduleTableView.reloadData()
            scheduleTableView.isHidden = false
            confirmationView.isHidden = true
            //show tableview
        case .time(let day):
            //show tableview
            //show back
            times = userAvailability.slotsForDay(date: day)
            scheduleTableView.reloadData()
            scheduleTableView.isHidden = false
            confirmationView.isHidden = true
        case .confirm(let date):
            //hide table view
            scheduleTableView.isHidden = true
            confirmationView.isHidden = false
        }
        
    }
}

extension ScheduleMeetingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch scheduleMode {
        case .day:
            scheduleMode = .time(date: days[indexPath.row])
        case .time(let date):
            scheduleMode = .confirm(date: times[indexPath.row])
        default:
            ()
        }
        
        if let userAvailability = userAvailability {
            updateForMode(userAvailability: userAvailability)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch scheduleMode {
        case .day:
            return days.count
        case .time(_):
            return times.count
        case .confirm(_):
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        
        switch scheduleMode {
        case .day:
            let date = days[indexPath.row]
            
            cell.textLabel?.text = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
            
        case .time(_):
            let date = times[indexPath.row]
            cell.textLabel?.text = DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
        case .confirm(_):
            ()
        }
        
        return cell
    }
    
}
