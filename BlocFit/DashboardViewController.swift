//
//  DashboardViewController.swift
//  BlocFit
//
//  Created by Colin Conduff on 10/1/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit

protocol DashboardUpdateDelegate: class {
    func updateViewModel(blocMembersCount: Int?,
                         totalSeconds: Double?,
                         meters: Double?,
                         score: Int?)
}

struct DashboardModel {
    var blocMembersCount: Int
    var totalSeconds: Double
    var meters: Double
    var score: Int
    
    init(blocMembersCount: Int, totalSeconds: Double, meters: Double, score: Int) {
        self.blocMembersCount = blocMembersCount
        self.totalSeconds = totalSeconds
        self.meters = meters
        self.score = score
    }
}

protocol DashboardViewModelProtocol: class {
    
    var dashboardModel: DashboardModel { get set }
    
    var blocMemberCount: String? { get }
    var time: String? { get }
    var distance: String? { get }
    var rate: String? { get }
    var score: String? { get }
    var distanceUnit: String? { get }
    var rateUnit: String? { get }
    
    var blocMemberCountDidChange: ((DashboardViewModelProtocol) -> ())? { get set }
    var timeDidChange: ((DashboardViewModelProtocol) -> ())? { get set }
    var distanceDidChange: ((DashboardViewModelProtocol) -> ())? { get set }
    var rateDidChange: ((DashboardViewModelProtocol) -> ())? { get set }
    var scoreDidChange: ((DashboardViewModelProtocol) -> ())? { get set }
    var distanceUnitDidChange: ((DashboardViewModelProtocol) -> ())? { get set }
    var rateUnitDidChange: ((DashboardViewModelProtocol) -> ())? { get set }
    
    init()
    
    func resetLabelValues()
}

class DashboardViewModel: DashboardViewModelProtocol {
    
    var dashboardModel: DashboardModel { didSet { setLabels() } }
    
    var blocMemberCount: String? { didSet { self.blocMemberCountDidChange?(self) } }
    var time: String? { didSet { self.timeDidChange?(self) } }
    var distance: String? { didSet { self.distanceDidChange?(self) } }
    var rate: String? { didSet { self.rateDidChange?(self) } }
    var score: String? { didSet { self.scoreDidChange?(self) } }
    var distanceUnit: String? { didSet { self.distanceUnitDidChange?(self) } }
    var rateUnit: String? { didSet { self.rateUnitDidChange?(self) } }
    
    var blocMemberCountDidChange: ((DashboardViewModelProtocol) -> ())?
    var timeDidChange: ((DashboardViewModelProtocol) -> ())?
    var distanceDidChange: ((DashboardViewModelProtocol) -> ())?
    var rateDidChange: ((DashboardViewModelProtocol) -> ())?
    var scoreDidChange: ((DashboardViewModelProtocol) -> ())?
    var distanceUnitDidChange: ((DashboardViewModelProtocol) -> ())?
    var rateUnitDidChange: ((DashboardViewModelProtocol) -> ())?
    
    required init() {
        self.dashboardModel = DashboardModel(blocMembersCount: 1, totalSeconds: 0,
                                             meters: 0, score: 0)
        setLabels()
    }
    
    func resetLabelValues() {
        setLabels()
    }
    
    private func setLabels() {
        let usingImperialUnits = BFUserDefaults.getUnitsSetting()
        
        blocMemberCount = String(dashboardModel.blocMembersCount + 1) // + 1 for owner
        time = BFFormatter.stringFrom(totalSeconds: dashboardModel.totalSeconds)
        
        let convertedDistance = BFUnitConverter.distanceFrom(meters: dashboardModel.meters,
                                                             isImperial: usingImperialUnits)
        distance = BFFormatter.stringFrom(number: convertedDistance)
        
        let rateInSeconds = (convertedDistance > 0) ? (dashboardModel.totalSeconds /
            convertedDistance) : 0
        rate = BFFormatter.stringFrom(totalSeconds: rateInSeconds)
        
        score = String(dashboardModel.score)
        
        let unitLabels = BFUnitConverter.unitLabels(isImperialUnits: usingImperialUnits)
        distanceUnit = unitLabels.distance
        rateUnit = unitLabels.rate
    }
}


class DashboardViewController: UIViewController, DashboardUpdateDelegate {
    
    @IBOutlet weak var distanceUnitsLabel: UILabel!
    @IBOutlet weak var rateUnitsLabel: UILabel!
    
    @IBOutlet weak var blocMemberCountLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var viewModel: DashboardViewModelProtocol! {
        didSet {
            viewModel.blocMemberCountDidChange = { [unowned self] viewModel in
                self.blocMemberCountLabel?.text = viewModel.blocMemberCount
            }
            viewModel.timeDidChange = { [unowned self] viewModel in
                self.timeLabel.text = viewModel.time
            }
            viewModel.distanceDidChange = { [unowned self] viewModel in
                self.distanceLabel.text = viewModel.distance
            }
            viewModel.rateDidChange = { [unowned self] viewModel in
                self.rateLabel.text = viewModel.rate
            }
            viewModel.scoreDidChange = { [unowned self] viewModel in
                self.scoreLabel.text = viewModel.score
            }
            viewModel.distanceUnitDidChange = { [unowned self] viewModel in
                self.distanceUnitsLabel.text = viewModel.distanceUnit
            }
            viewModel.rateUnitDidChange = { [unowned self] viewModel in
                self.rateUnitsLabel.text = viewModel.rateUnit
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = DashboardViewModel()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewModel.resetLabelValues()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // DashboardUpdateDelegate method
    func updateViewModel(blocMembersCount: Int? = nil,
                         totalSeconds: Double? = nil,
                         meters: Double? = nil,
                         score: Int? = nil) {
        if let blocMembersCount = blocMembersCount {
            viewModel.dashboardModel.blocMembersCount = blocMembersCount
        }
        if let totalSeconds = totalSeconds {
            viewModel.dashboardModel.totalSeconds = totalSeconds
        }
        if let meters = meters {
            viewModel.dashboardModel.meters = meters
        }
        if let score = score {
            viewModel.dashboardModel.score = score
        }
    }
}
