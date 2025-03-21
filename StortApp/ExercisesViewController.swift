//
//  ExercisesViewController.swift
//  StortApp
//
//  Created by Николай Игнатов on 19.03.2025.
//

import UIKit

final class ExercisesViewController: UIViewController {
    // MARK: - Properties
    let networkService: NetworkServiceProtocol = NetworkService()
    private var exercises: [ExerciseModel] = []
    private var selectedItems: [Int: IndexPath] = [:]
    private var selectedType: String?
    private var selectedMuscle: String?
    private var selectedDifficulty: String?
    
    // MARK: - UI Components
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Поиск упражнений"
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private lazy var filtersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(FilterCell.self, forCellWithReuseIdentifier: "FilterCell")
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "HeaderView"
        )
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.isScrollEnabled = false
        collectionView.allowsMultipleSelection = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var resultsTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ExerciseCell.self, forCellReuseIdentifier: "ExerciseCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.keyboardDismissMode = .onDrag
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Filter Sections Data
    private struct FilterSection {
        let title: String
        let items: [String]
    }
    
    private let sections: [FilterSection] = [
        FilterSection(title: "Тип упражнения", items: [
            "Cardio", "Olympic Weightlifting", "Plyometrics",
            "Powerlifting", "Strength", "Stretching", "Strongman"
        ]),
        FilterSection(title: "Целевые мышцы", items: [
            "Abdominals", "Abductors", "Adductors", "Biceps",
            "Calves", "Chest", "Forearms", "Glutes",
            "Hamstrings", "Lats", "Lower Back", "Middle Back",
            "Neck", "Quadriceps", "Traps", "Triceps"
        ]),
        FilterSection(title: "Уровень сложности", items: [
            "Beginner", "Intermediate", "Expert"
        ])
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    // MARK: - Private Methods
    private func setupView() {
        view.backgroundColor = .white
        title = "Упражнения"
        
        view.addSubview(searchBar)
        view.addSubview(filtersCollectionView)
        view.addSubview(resultsTableView)
        view.addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            filtersCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            filtersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filtersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filtersCollectionView.heightAnchor.constraint(equalToConstant: 500),
            
            resultsTableView.topAnchor.constraint(equalTo: filtersCollectionView.bottomAnchor),
            resultsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    private func fetchExercises() {
        activityIndicator.startAnimating()
        
        let parameters = ExerciseQueryParameters(
            name: searchBar.text,
            type: selectedType,
            muscle: selectedMuscle,
            difficulty: selectedDifficulty?.lowercased()
        )
        
        networkService.fetchExercises(parameters: parameters) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                switch result {
                case .success(let exercises):
                    self.exercises = exercises
                    self.resultsTableView.reloadData()
                case .failure(let error):
                    print("Error: \(error)")
                    self.exercises.removeAll()
                    self.resultsTableView.reloadData()
                }
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ExercisesViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as? FilterCell else {
            return UICollectionViewCell()
        }
        
        let item = sections[indexPath.section].items[indexPath.item]
        cell.configure(with: item)
        
        if let selectedIndexPath = selectedItems[indexPath.section],
           selectedIndexPath == indexPath {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            cell.isSelected = true
        } else {
            cell.isSelected = false
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "HeaderView",
                for: indexPath
              ) as? SectionHeaderView else {
            return UICollectionReusableView()
        }
        
        header.configure(with: sections[indexPath.section].title)
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ExercisesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = sections[indexPath.section].items[indexPath.item]
        let font = UIFont.systemFont(ofSize: 14)
        let width = text.size(withAttributes: [.font: font]).width + 32
        return CGSize(width: width, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = sections[indexPath.section].items[indexPath.item]
        
        if let previousSelectedIndexPath = selectedItems[indexPath.section],
           previousSelectedIndexPath == indexPath {
            collectionView.deselectItem(at: indexPath, animated: true)
            selectedItems.removeValue(forKey: indexPath.section)
            
            switch indexPath.section {
            case 0: selectedType = nil
            case 1: selectedMuscle = nil
            case 2: selectedDifficulty = nil
            default: break
            }
        } else {
            if let previousSelectedIndexPath = selectedItems[indexPath.section] {
                collectionView.deselectItem(at: previousSelectedIndexPath, animated: true)
            }
            
            selectedItems[indexPath.section] = indexPath
            
            switch indexPath.section {
            case 0: selectedType = selectedItem
            case 1: selectedMuscle = selectedItem.lowercased()
            case 2: selectedDifficulty = selectedItem.lowercased()
            default: break
            }
        }
        
        fetchExercises()
    }
    
}

// MARK: - UITableViewDataSource
extension ExercisesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseCell", for: indexPath) as? ExerciseCell else {
            return UITableViewCell()
        }
        cell.configure(with: exercises[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ExercisesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension ExercisesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch), object: nil)
        perform(#selector(performSearch), with: nil, afterDelay: 0.5)
    }
    
    @objc private func performSearch() {
        fetchExercises()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        fetchExercises()
    }
}
