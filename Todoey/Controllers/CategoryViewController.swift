//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Moon Yeji on 2022/11/01.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import CoreData
import UIKit

final class CategoryViewController: UITableViewController {

    var categories :[ItemCategory] = []
    let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    lazy var backgroundContext: NSManagedObjectContext = self.container.newBackgroundContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        configureNavigationBar()
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.barStyle = .black
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(
            red: 0.448,
            green: 0.766,
            blue: 0.937,
            alpha: 1)
        appearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    @IBAction func addButtonDidTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(
            title: "새로운 카테고리 추가",
            message: "이름을 지어주세요",
            preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "카테고리 작성"
        }
        let confirmAction = UIAlertAction(
            title: "OK",
            style: .default) { _ in
                if let title = alert.textFields?.first?.text,
                   !title.isEmpty {
                    self.createCategory(withTitle: title)
                    self.loadItems()
                }
            }
        alert.addAction(confirmAction)
        
        present(alert, animated: true)
    }
    
    func loadItems() {
        backgroundContext.perform { [unowned self] in
            let request = ItemCategory.fetchRequest()
            do {
                self.categories = try self.backgroundContext.fetch(request)
            } catch {
                print("Error fetching categories \(error)")
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func createCategory(withTitle title: String) {
        backgroundContext.perform { [unowned self] in
            let newCategory = ItemCategory(context: self.backgroundContext)
            newCategory.name = title
        }
        save()
    }
    
    func save() {
        backgroundContext.perform { [unowned self] in
            do {
                try self.backgroundContext.save()
            } catch {
                print("Error Saving \(error)")
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int)
    -> Int
    {
        return categories.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath)
    -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "CategoryCell",
            for: indexPath)
        let category = categories[indexPath.row]
        
        if #available(iOS 14.0, *) {
            var configuration = cell.defaultContentConfiguration()
            configuration.text = category.name
            cell.contentConfiguration = configuration
        } else {
            cell.textLabel?.text = category.name
        }
        
        return cell
    }
    
    // MARK: - Table View Delegate Methods
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! TodoListViewController
        if let selectedCategoryIndex = tableView.indexPathForSelectedRow?.row {
            destination.selectedCategoryID = categories[selectedCategoryIndex].objectID
        }
    }

}
