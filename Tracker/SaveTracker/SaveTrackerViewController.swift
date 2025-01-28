//
//  HabitCreationViewController.swift
//  Tracker
//
//  Created by Alibi Mailan
//


import UIKit

protocol SaveTrackerViewControllerDelegate: AnyObject {
    func appendTracker(tracker: Tracker, category: String?)
    func updateTracker(tracker: Tracker, oldTracker: Tracker?, category: String?)
    func reload()
}

final class SaveTrackerViewController: UIViewController {
    
    weak var delegate: SaveTrackerViewControllerDelegate?
    
    private let emojis = ["🙂","😻","🌺","🐶","❤️","😱","😇","😡","🥶","🤔","🙌","🍔","🥦","🏓","🥇","🎸","🏝","😪"]
    private let colors: [UIColor] =
    [.trackerColor1, .trackerColor2, .trackerColor3, .trackerColor4, .trackerColor5, .trackerColor6, .trackerColor7, .trackerColor8, .trackerColor9, .trackerColor10, .trackerColor11, .trackerColor12, .trackerColor13, .trackerColor14, .trackerColor15, .trackerColor16, .trackerColor17, .trackerColor18]
    
    private let saveButton = PrimaryButton(title: "Создать")
    private let nameMaxLengthErrorLabel = UILabel()
    private let nameTextField = UITextField.primary("Введите название трекера")
    private(set) var viewModel = TrackerCategoryViewModel.shared
    private var buttonsTableView = ButtonsTableView(items: [])
    
    private var selectedColorIndex: Int?
    private var selectedEmojiIndex: Int?
    private var selectedDays: Set<DayOfWeek> = []
    
    private lazy var nameMaxLengthErrorLabelHideConstraint = nameMaxLengthErrorLabel.heightAnchor.constraint(equalToConstant: 0)
    private lazy var nameMaxLengthErrorLabelShowConstraint = nameMaxLengthErrorLabel.heightAnchor.constraint(equalToConstant: 38)

    var oldSelectedCategory: TrackerCategory? = nil
    var selectedCategory: TrackerCategory? = nil
    var editingTracker: Tracker? = nil
    var isRegular: Bool = true
    var isEdit: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkButtonShouldBeEnabled()
    }
    
    private func setupUI() {
        view.backgroundColor = .ypBackgroundLight
        navigationItem.hidesBackButton = true
        
        if (isRegular) {
            buttonsTableView = ButtonsTableView(items: [
                .init(title: "Категория"),
                .init(title: "Расписание")
            ])
        } else {
            buttonsTableView = ButtonsTableView(items: [
                .init(title: "Категория")
            ])
        }
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        nameTextField.addTarget(self, action: #selector(nameDidChange(_:)), for: .editingChanged)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.delegate = self
        nameTextField.returnKeyType = .done
        scrollView.addSubview(nameTextField)
        
        nameMaxLengthErrorLabel.text = "Ограничение 38 символов"
        nameMaxLengthErrorLabel.textColor = UIColor(hex: "#F56B6C")
        nameMaxLengthErrorLabel.font = UIFont.systemFont(ofSize: 17)
        nameMaxLengthErrorLabel.textAlignment = .center
        nameMaxLengthErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(nameMaxLengthErrorLabel)
        
        buttonsTableView.onItemSelected = { [weak self] selectedIndex in
            guard let self = self else {
                return
            }
            if (selectedIndex == 0) {
                let trackerCategoryVC = TrackerCategoryViewController()
                trackerCategoryVC.delegate = self
                self.navigationController?.pushViewController(trackerCategoryVC, animated: true)
            }
            else {
                let trackerScheduleVC = TrackerScheduleViewController()
                trackerScheduleVC.delegate = self
                self.navigationController?.pushViewController(trackerScheduleVC, animated: true)
            }
        }
        
        buttonsTableView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(buttonsTableView)
        
        let emojisLabel = sectionTitleLabel("Emoji")
        let emojisCollectionView = SelectItemCollectionView(items: emojis, selectedIndex: selectedEmojiIndex)
        emojisCollectionView.onItemSelected = { [weak self] index in
            self?.selectedEmojiIndex = index
            self?.checkButtonShouldBeEnabled()
        }
        emojisCollectionView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(emojisLabel)
        scrollView.addSubview(emojisCollectionView)
        
        let colorsLabel = sectionTitleLabel("Цвет")
        let colorsCollectionView = SelectItemCollectionView(items: colors, selectedIndex: selectedColorIndex)
        colorsCollectionView.onItemSelected = { [weak self] index in
            self?.selectedColorIndex = index
            self?.checkButtonShouldBeEnabled()
        }
        colorsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(colorsLabel)
        scrollView.addSubview(colorsCollectionView)
        
        let actionButtonsStackView = UIStackView()
        actionButtonsStackView.axis = .horizontal
        actionButtonsStackView.distribution = .fillEqually
        actionButtonsStackView.spacing = 8
        actionButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        saveButton.addTarget(self, action: #selector(onClickSave), for: .touchUpInside)
        
        let cancelButton = UIButton.cancelButton("Отменить")
        cancelButton.addTarget(self, action: #selector(onClickCancel), for: .touchUpInside)
        
        actionButtonsStackView.addArrangedSubview(cancelButton)
        actionButtonsStackView.addArrangedSubview(saveButton)
        
        scrollView.addSubview(actionButtonsStackView)
        
        if (isEdit) {
            buttonsTableView.updateSubtitle(index: 0, subtitle: selectedCategory?.name ?? "")
            navigationItem.title = "Редактирование привычки"
            saveButton.setTitle("Сохранить", for: .normal)
            if (isRegular) {
                save(weekDays: editingTracker?.schedule ?? [])
            }
        } else {
            navigationItem.title = "Новая привычка"
        }
        
        let mainLayout = scrollView.contentLayoutGuide
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: mainLayout.topAnchor, constant: 16),
            nameTextField.leadingAnchor.constraint(equalTo: mainLayout.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: mainLayout.trailingAnchor, constant: -16),
            
            nameMaxLengthErrorLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor),
            nameMaxLengthErrorLabel.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            nameMaxLengthErrorLabel.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            nameMaxLengthErrorLabelHideConstraint,
            
            buttonsTableView.topAnchor.constraint(equalTo: nameMaxLengthErrorLabel.bottomAnchor, constant: 24),
            buttonsTableView.leadingAnchor.constraint(equalTo: mainLayout.leadingAnchor, constant: 16),
            buttonsTableView.trailingAnchor.constraint(equalTo: mainLayout.trailingAnchor, constant: -16),
            buttonsTableView.heightAnchor.constraint(equalToConstant: isRegular ? 150 : 75),
            
            emojisLabel.topAnchor.constraint(equalTo: buttonsTableView.bottomAnchor, constant: 32),
            emojisLabel.leadingAnchor.constraint(equalTo: mainLayout.leadingAnchor, constant: 28),
            emojisLabel.trailingAnchor.constraint(equalTo: mainLayout.trailingAnchor, constant: -28),
            
            emojisCollectionView.topAnchor.constraint(equalTo: emojisLabel.bottomAnchor, constant: 24),
            emojisCollectionView.leadingAnchor.constraint(equalTo: mainLayout.leadingAnchor, constant: 16),
            emojisCollectionView.trailingAnchor.constraint(equalTo: mainLayout.trailingAnchor, constant: -16),
            emojisCollectionView.heightAnchor.constraint(equalToConstant: 52*3),
            
            colorsLabel.topAnchor.constraint(equalTo: emojisCollectionView.bottomAnchor, constant: 16),
            colorsLabel.leadingAnchor.constraint(equalTo: mainLayout.leadingAnchor, constant: 28),
            colorsLabel.trailingAnchor.constraint(equalTo: mainLayout.trailingAnchor, constant: -28),
            
            colorsCollectionView.topAnchor.constraint(equalTo: colorsLabel.bottomAnchor, constant: 24),
            colorsCollectionView.leadingAnchor.constraint(equalTo: mainLayout.leadingAnchor, constant: 16),
            colorsCollectionView.trailingAnchor.constraint(equalTo: mainLayout.trailingAnchor, constant: -16),
            colorsCollectionView.heightAnchor.constraint(equalToConstant: 52*3),
            
            actionButtonsStackView.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 40),
            actionButtonsStackView.leadingAnchor.constraint(equalTo: mainLayout.leadingAnchor, constant: 16),
            actionButtonsStackView.trailingAnchor.constraint(equalTo: mainLayout.trailingAnchor, constant: -16),
            actionButtonsStackView.heightAnchor.constraint(equalToConstant: 60),
            actionButtonsStackView.bottomAnchor.constraint(equalTo: mainLayout.bottomAnchor, constant: -16)
        ])
    }
    
    private func sectionTitleLabel(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    @objc private func onClickSave() {
        guard let text = nameTextField.text, !text.isEmpty,
              let emojiIndex = selectedEmojiIndex,
              let colorIndex = selectedColorIndex
        else {
            return
        }
        
        let newTracker = Tracker(id: editingTracker?.id ?? UUID(),
                                 name: text,
                                 color: colors[colorIndex],
                                 emoji: emojis[emojiIndex],
                                 schedule: selectedDays,
                                 pinned: false)
        if isEdit, let editingTracker = editingTracker {
            viewModel.removeTrackerFromCategory(of: oldSelectedCategory, tracker: editingTracker)
            delegate?.updateTracker(tracker: newTracker, oldTracker: editingTracker, category: selectedCategory?.name)
        } else {
            delegate?.appendTracker(tracker: newTracker, category: selectedCategory?.name)
        }
        viewModel.addTrackerToCategory(to: selectedCategory, tracker: newTracker)
        delegate?.reload()
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc private func onClickCancel() {
        navigationController?.dismiss(animated: true)
    }
    
    
    @objc private func nameDidChange(_ textField: UITextField) {
        let value = textField.text ?? ""
        if (value.count > 38) {
            showNameMaxLengthErrorLabel()
        } else {
            hideNameMaxLengthErrorLabel()
        }
        checkButtonShouldBeEnabled()
    }
    
    private func showNameMaxLengthErrorLabel() {
        nameMaxLengthErrorLabelHideConstraint.isActive = false
        nameMaxLengthErrorLabelShowConstraint.isActive = true
    }
    
    private func hideNameMaxLengthErrorLabel() {
        nameMaxLengthErrorLabelShowConstraint.isActive = false
        nameMaxLengthErrorLabelHideConstraint.isActive = true
    }
    
    public func edit(tracker: Tracker, category: TrackerCategory?) {
        isEdit = true
        editingTracker = tracker
        nameTextField.text = tracker.name
        selectedDays = tracker.schedule ?? []
        isRegular = tracker.schedule != nil
        selectedCategory = category
        oldSelectedCategory = category
        if let selectedEmoji = editingTracker?.emoji {
            selectedEmojiIndex = emojis.firstIndex(of: selectedEmoji)
        }
        if let selectedColor = editingTracker?.color {
            selectedColorIndex = colors.firstIndex(where: { $0.isEqualToColor(selectedColor) })
        }
    }
    
    public func checkButtonShouldBeEnabled() {
        if nameTextField.text == nil || nameTextField.text?.isEmpty == true
              || (nameTextField.text?.count ?? 0) > 38
              || selectedEmojiIndex == nil
              || selectedColorIndex == nil {
            saveButton.disable()
        } else {
            saveButton.enable()
        }
    }
}

extension SaveTrackerViewController: TrackerScheduleDelegate {
    func save(weekDays: Set<DayOfWeek>) {
        selectedDays = weekDays
        
        var subtitle = ""
        
        if !selectedDays.isEmpty {
            if selectedDays.count == 7 {
                subtitle = "Каждый день"
            } else {
                subtitle = selectedDays.sorted { $0.rawValue < $1.rawValue }.map { $0.shortDaysName }.joined(separator: ", ")
            }
        }
        
        buttonsTableView.updateSubtitle(index: 1, subtitle: subtitle)
    }
}

extension SaveTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension SaveTrackerViewController: TrackerCategoryDelegate {
    func onSelect(category: TrackerCategory) {
        selectedCategory = category
        buttonsTableView.updateSubtitle(index: 0, subtitle: category.name)
        checkButtonShouldBeEnabled()
    }
}
