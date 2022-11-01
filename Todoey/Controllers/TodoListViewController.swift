//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import CoreData
import UIKit

final class TodoListViewController: UITableViewController {
    
    var items :[Item] = []
    let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    lazy var backgroundContext: NSManagedObjectContext = self.container.newBackgroundContext()
    
    var selectedCategoryID: NSManagedObjectID? {
        willSet(id) {
            selectedCategory = backgroundContext.object(with: id!) as? ItemCategory
        }
    }
    
    var selectedCategory: ItemCategory? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - TableView DataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int)
    -> Int
    {
        return items.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath)
    -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TodoItemCell",
            for: indexPath)
        let item = items[indexPath.row]
        
        if #available(iOS 14.0, *) {
            var configuration = cell.defaultContentConfiguration()
            configuration.text = item.title
            cell.contentConfiguration = configuration
        } else {
            cell.textLabel?.text = item.title
        }
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath)
    {
        backgroundContext.perform {
            self.items[indexPath.row].done = !self.items[indexPath.row].done
        }
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Add New Item
    
    @IBAction func addButtonDidPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(
            title: "투두이 아이템 추가",
            message: "",
            preferredStyle: .alert)
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "새로운 할 일 작성"
        }
        
        let addAction = UIAlertAction(
            title: "추가",
            style: .default)
        { [unowned self] _ in
            if let title = alert.textFields?.first?.text,
               !title.isEmpty {
                self.createItem(withTitle: title)
                self.loadItems()
                self.tableView.reloadData()
            }
        }
        alert.addAction(addAction)
        
        present(alert, animated: true)
    }
    
    func createItem(withTitle title: String) {
        backgroundContext.perform { [unowned self] in
            let newItem  = Item(context: self.backgroundContext)
            newItem.done = false
            newItem.title = title
            newItem.parentCategory = self.selectedCategory
            self.items.append(newItem)
            do {
                try self.backgroundContext.save()
            } catch {
                print("CoreData save error \(error)")
            }
        }
    }
    
    func loadItems(
        with request: NSFetchRequest<Item> = Item.fetchRequest(),
        predicate: NSPredicate? = nil)
    {
        backgroundContext.perform {
            let categoryPredicate = NSPredicate(
                format: "parentCategory.name MATCHES %@",
                self.selectedCategory!.name!)
            
            if let additionalPredicate = predicate {
                let compoundPredicate = NSCompoundPredicate(
                    andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
                request.predicate = compoundPredicate
            } else {
                request.predicate = categoryPredicate
            }
            
            do {
                self.items = try self.backgroundContext.fetch(request)
            } catch {
                print("Error fetching items \(error)")
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func saveItems() {
        backgroundContext.perform { [unowned self] in
            do {
                try self.backgroundContext.save()
            } catch {
                print("CoreData save error \(error)")
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
}

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request = Item.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.isEmpty {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
