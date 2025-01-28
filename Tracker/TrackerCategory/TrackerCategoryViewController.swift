//
//  TrackerCategoryViewController.swift
//  Tracker
//
//  Created by Alibi Mailan
//

import UIKit

protocol TrackerCategoryDelegate: AnyObject {
    func onSelect(category: TrackerCategory)
}

final class TrackerCategoryViewController: UIViewController {
    
    weak var delegate: TrackerCategoryDelegate?
    
    private var applyButton = PrimaryButton(title: "Добавить категорию")
    
    private var categoriesTableView: SelectItemTableView?
    private let emptyCategoryLogo = UIImageView()
    private let emptyCategoryText = UILabel()
    
    private(set) var viewModel = TrackerCategoryViewModel.shared
    
    override func viewDidLoad() {
        setupUI()
        checkEmptyCategoriesScreen()
    }
    
    private func setupUI() {
        view.backgroundColor = .ypBackgroundLight
        navigationItem.hidesBackButton = true
        navigationItem.title = "Категория"
        
        categoriesTableView = SelectItemTableView(items: viewModel.categories.map(\.self.name))
        guard let categoriesTableView = categoriesTableView else { return }
        categoriesTableView.onItemSelected = { [weak self] index in
            guard let index = index, let category = self?.viewModel.categories[index] else {
                return
            }
            self?.delegate?.onSelect(category: category)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self?.navigationController?.popViewController(animated: true)
            }
        }
        categoriesTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(categoriesTableView)
        
        emptyCategoryLogo.translatesAutoresizingMaskIntoConstraints = false
        emptyCategoryLogo.image = UIImage(named: "Empty trackers")
        view.addSubview(emptyCategoryLogo)
        
        emptyCategoryText.translatesAutoresizingMaskIntoConstraints = false
        emptyCategoryText.text = "Привычки и события можно\nобъединить по смыслу"
        emptyCategoryText.textColor = .black
        emptyCategoryText.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        emptyCategoryText.numberOfLines = 2
        emptyCategoryText.textAlignment = .center
        view.addSubview(emptyCategoryText)
        
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        applyButton.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
        view.addSubview(applyButton)
        
        NSLayoutConstraint.activate([
            categoriesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoriesTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoriesTableView.bottomAnchor.constraint(equalTo: applyButton.topAnchor, constant: -24),
            emptyCategoryLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyCategoryLogo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 246),
            emptyCategoryLogo.heightAnchor.constraint(equalToConstant: 80),
            emptyCategoryLogo.widthAnchor.constraint(equalToConstant: 80),
            emptyCategoryText.centerXAnchor.constraint(equalTo: emptyCategoryLogo.centerXAnchor),
            emptyCategoryText.topAnchor.constraint(equalTo: emptyCategoryLogo.bottomAnchor, constant: 8),
            applyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            applyButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            applyButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            applyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func checkEmptyCategoriesScreen() {
        if viewModel.categories.isEmpty {
            categoriesTableView?.setEmptyMessage("Привычки и события можно объединить по смыслу?", UIImage(named: "il-error-1") ?? UIImage())
        } else {
            categoriesTableView?.restoreBackgroundView()
        }
        categoriesTableView?.reloadData()
    }
    
    @objc private func addCategoryTapped() {
        let сreateCategoryViewController = AddTrackerCategoryViewController()
        сreateCategoryViewController.categoryViewController = self
        navigationController?.pushViewController(сreateCategoryViewController, animated: true)
    }
}

// MARK: - CategoryActions
extension TrackerCategoryViewController: AddTrackerCategoryActions {
    func updateCategory(category: TrackerCategory?, name: String) {
        viewModel.addCategory(name)
    }
    
    func appendCategory(category: String) {
        viewModel.addCategory(category)
        categoriesTableView?.updateItems(viewModel.categories.map(\.self.name))
        checkEmptyCategoriesScreen()
    }
    
    func reload() {
        categoriesTableView?.reloadData()
    }
}
