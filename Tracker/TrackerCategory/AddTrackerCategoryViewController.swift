//
//  TrackerCategoryViewController.swift
//  Tracker
//
//  Created by Alibi Mailan
//

import UIKit

protocol AddTrackerCategoryActions {
    func appendCategory(category: String)
    func updateCategory(category: TrackerCategory?, name: String)
    func reload()
}

final class AddTrackerCategoryViewController: UIViewController {
    
    var categoryViewController: AddTrackerCategoryActions?
    var categoryToEdit: TrackerCategory?
    
    private let categoryNameField = UITextField.primary("Введите название категории")
    private let doneButton = PrimaryButton(title: "Готово")
    

    override func viewDidLoad() {
        view.backgroundColor = .ypBackgroundLight
        navigationItem.hidesBackButton = true
        navigationItem.title = categoryToEdit != nil ? "Редактировать категорию" : "Новая категория"
        
        categoryNameField.addTarget(self, action: #selector(nameDidChange(_:)), for: .editingChanged)
        categoryNameField.translatesAutoresizingMaskIntoConstraints = false
        categoryNameField.delegate = self
        categoryNameField.returnKeyType = .done
        view.addSubview(categoryNameField)
    
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.isEnabled = false
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            categoryNameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoryNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func editCategory(_ category: TrackerCategory, newHeader: String) {
        categoryToEdit = category
        categoryNameField.text = category.name
    }
    
    @objc private func doneButtonTapped() {
        guard let category = categoryNameField.text, !category.isEmpty else {
            return
        }
        if categoryToEdit != nil {
            categoryViewController?.updateCategory(category: categoryToEdit, name: category)
        } else {
            categoryViewController?.appendCategory(category: category)
        }
        categoryViewController?.reload()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func nameDidChange(_ textField: UITextField) {
        if textField.text?.isEmpty ?? false {
            doneButton.isEnabled = false
            doneButton.backgroundColor = .gray
        } else {
            doneButton.isEnabled = true
            doneButton.backgroundColor = .black
        }
    }
}

extension AddTrackerCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
