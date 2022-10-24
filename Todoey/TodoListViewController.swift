//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    var items = ["take a shower", "buy lunch", "go running"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .black
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(red: 0.448, green: 0.766, blue: 0.937, alpha: 1)
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
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
        numberOfRowsInSection section: Int
    ) -> Int {
        return items.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        if #available(iOS 14.0, *) {
            var configuration = cell.defaultContentConfiguration()
            configuration.text = items[indexPath.row]
            cell.contentConfiguration = configuration
        } else {
            cell.textLabel?.text = items[indexPath.row]
        }
                
        return cell
    }

    // MARK: - TableView Delegate
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.accessoryType == .checkmark {
            cell?.accessoryType = .none
        } else {
            cell?.accessoryType = .checkmark
        }
    
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Add New Item
    
    @IBAction func addButtonDidPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "투두이 아이템 추가", message: "", preferredStyle: .alert)
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "새로운 할 일 작성"
        }
        
        let addAction = UIAlertAction(title: "추가", style: .default) { _ in
            if let item = alert.textFields?.first?.text,
               !item.isEmpty {
                self.items.append(item)
                self.tableView.reloadData()
            }
        }
        alert.addAction(addAction)
        
        present(alert, animated: true)
    }
    
}
