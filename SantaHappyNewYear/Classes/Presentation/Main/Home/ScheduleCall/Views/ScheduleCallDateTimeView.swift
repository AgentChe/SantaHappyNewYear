//
//  ScheduleCallDateTimeView.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 03.10.2025.
//

//
//  ScheduleCallDateTimeView.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 03.10.2025.
//

import UIKit

final class ScheduleCallDateTimeView: UIView {
    enum DateTime {
        case date, time
    }
    
    private(set) var selectedDate: Date
    
    lazy var titleLabel = makeTitleLabel()
    lazy var valueButton = makeValueButton()
    lazy var hiddenTextField = makeHiddenTextField()
    lazy var datePicker = makeDatePicker()

    private let dateTime: DateTime
    
    private lazy var valueAttrs = TextAttributes()
        .textColor(Appearance.mono200)
        .font(Fonts.SFProRounded.regular(size: 17.scale))

    init(dateTime: DateTime) {
        self.dateTime = dateTime
        self.selectedDate = Date()
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
        updateValueTitle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension ScheduleCallDateTimeView {
    func initialize() {
        backgroundColor = Appearance.main200
        layer.cornerRadius = 24.scale
    }

    @objc
    func valueTapped() {
        datePicker.setDate(selectedDate, animated: false)
        hiddenTextField.becomeFirstResponder()
    }

    @objc
    func pickerChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        updateValueTitle()
    }

    @objc
    func doneTapped() {
        selectedDate = datePicker.date
        updateValueTitle()
        hiddenTextField.resignFirstResponder()
    }

    @objc
    func cancelTapped() {
        hiddenTextField.resignFirstResponder()
    }

    func updateValueTitle() {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.calendar = .current

        switch dateTime {
        case .date:
            formatter.setLocalizedDateFormatFromTemplate("d MMM yyyy")
        case .time:
            formatter.timeStyle = .short
            formatter.dateStyle = .none
        }

        let text = formatter.string(from: selectedDate)
        valueButton.setAttributedTitle(text.attributed(with: valueAttrs), for: .normal)
        valueButton.setNeedsLayout()
    }
}

// MARK: Make constraints
private extension ScheduleCallDateTimeView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            valueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            valueButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueButton.heightAnchor.constraint(equalToConstant: 34.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ScheduleCallDateTimeView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.SFProRounded.regular(size: 17.scale))
            .lineHeight(22.scale)
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = {
            switch dateTime {
            case .date: return "ScheduleCall.Date".localized.attributed(with: attrs)
            case .time: return "ScheduleCall.Time".localized.attributed(with: attrs)
            }
        }()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeValueButton() -> UIButton {
        let view = UIButton()
        view.backgroundColor = UIColor(integralRed: 118, green: 118, blue: 128, alpha: 0.12)
        view.layer.cornerRadius = 6.scale
        view.contentEdgeInsets = UIEdgeInsets(vertical: 6.scale, horizontal: 11.scale)
        view.addTarget(self, action: #selector(valueTapped), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeHiddenTextField() -> UITextField {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.inputView = datePicker

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let cancel = UIBarButtonItem(title: "Cancel".localized, style: .plain, target: self, action: #selector(cancelTapped))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done".localized, style: .done, target: self, action: #selector(doneTapped))
        toolbar.items = [cancel, flex, done]
        view.inputAccessoryView = toolbar

        addSubview(view)
        return view
    }

    func makeDatePicker() -> UIDatePicker {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .wheels
        switch dateTime {
        case .date:
            picker.datePickerMode = .date
        case .time:
            picker.datePickerMode = .time
        }
        picker.locale = .current
        picker.calendar = .current
        picker.addTarget(self, action: #selector(pickerChanged(_:)), for: .valueChanged)
        return picker
    }
}
