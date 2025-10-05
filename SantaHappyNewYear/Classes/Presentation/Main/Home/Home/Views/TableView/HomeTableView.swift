//
//  HomeTableView.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 05.10.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeTableView: UITableView {
    private lazy var elements = [ScheduleCall]()
    
    private let didEditTrigger = PublishRelay<ScheduleCall>()
    private let didCallTrigger = PublishRelay<ScheduleCall>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension HomeTableView {
    func setup(elements: [ScheduleCall]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didEdit: Signal<ScheduleCall> {
        didEditTrigger.asSignal()
    }
    
    var didCall: Signal<ScheduleCall> {
        didCallTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension HomeTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = elements[indexPath.row]
        let cell = dequeueReusableCell(withIdentifier: String(describing: HomeTableScheduleCell.self), for: indexPath) as! HomeTableScheduleCell
        cell.setup(scheduleCall: element)
        cell.didTapEdit = { [weak self] in
            self?.didEditTrigger.accept(element)
        }
        cell.didTapCall = { [weak self] in
            self?.didCallTrigger.accept(element)
        }
        return cell
    }
}

// MARK: UITableViewDelegate
extension HomeTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: Private
private extension HomeTableView {
    func initialize() {
        backgroundColor = UIColor.clear
        contentInset = UIEdgeInsets(t: 8.scale, b: 90.scale)
        setContentOffset(CGPoint(x: 0, y: -8.scale), animated: false)
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        contentInsetAdjustmentBehavior = .never
        
        register(HomeTableScheduleCell.self, forCellReuseIdentifier: String(describing: HomeTableScheduleCell.self))
        
        dataSource = self
        delegate = self
    }
}
