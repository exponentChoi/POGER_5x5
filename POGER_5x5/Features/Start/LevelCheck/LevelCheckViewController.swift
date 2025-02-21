//
//  LevelCheckViewController.swift
//  POGER_5x5
//
//  Created by 이서준 on 2023/02/03.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

class LevelCheckViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    let scrollView = UIScrollView().then {
        $0.isScrollEnabled = false
        $0.backgroundColor = .clear
        $0.alwaysBounceVertical = true
    }
    
    let scrollViewContainer = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let levelCheckDescriptionLabel = UILabel().then {
        $0.text = "본인의 최고 1회기록(1RM)의\n80% 무게값으로 설정하시는걸 권장드려요."
        $0.textColor = .label
        $0.font = .preferredFont(forTextStyle: .body)
        $0.textAlignment = .left
        $0.numberOfLines = 0
    }
    
    let tableView = DynamicHeightTableView().then {
        $0.isScrollEnabled = false
        $0.estimatedRowHeight = 44
        $0.rowHeight = UITableView.automaticDimension
        $0.backgroundColor = .secondarySystemBackground
        $0.layer.cornerRadius = 12
        $0.register(InputListCell.self, forCellReuseIdentifier: InputListCell.identifier)
    }
    
    let nextButton = UIButton.commonButton(title: "계속")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: 훈련 환경 입력 화면으로 Push시에 BackButton 타이틀이 "스트렝스 레벨 입력"이 아닌 "Back"으로 표시되는 문제 원인 파악
        self.title = "스트렝스 레벨 입력"
        view.backgroundColor = .systemBackground
        setupLayout()
        bind()
    }
    
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        scrollView.addSubview(scrollViewContainer)
        scrollViewContainer.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.size.width)
        }
        
        scrollViewContainer.addSubview(levelCheckDescriptionLabel)
        levelCheckDescriptionLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        scrollViewContainer.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(levelCheckDescriptionLabel.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.greaterThanOrEqualTo(tableView.contentSize.height)
        }
        
        
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.bottom)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-52)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(52)
        }
    }
    
    private func bind() {
        Observable.just(Training.allCases)
            .bind(to: tableView.rx.items(
                cellIdentifier: InputListCell.identifier,
                cellType: InputListCell.self)
            ) { row, element, cell in
                cell.model = element
                
                cell.pickerButton.rx.tap
                    .bind(to: cell.pickerButton.didTapButtonStream)
                    .disposed(by: cell.disposeBag)
            }.disposed(by: disposeBag)
        
        nextButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                let trainingEnvironmentViewController = TrainingEnvironmentViewController()
                owner.navigationController?.pushViewController(trainingEnvironmentViewController, animated: true)
            }).disposed(by: disposeBag)
    }
}
