//
//  ViewController.swift
//  TaskListApp
//
//  Created by NikolayD on 26.08.2024.
//

import UIKit

final class TaskListViewController: UITableViewController {
    
    private let storageManager = StorageManager.shared
    
    private var taskList: [ToDoTask] = []
    private let cellID = "task"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        fetchData()
    }
    
    @objc private func addNewTask() {
        showAlert(
            withTitle: "New Task",
            andMessage: "What do you want to do") { textField in
                textField.placeholder = "New Task"
            } saveButtonCompletion: { [unowned self] taskName in
                save(taskName)
            }
    }
    
    private func fetchData() {
        storageManager.fetchTaskList { [unowned self] result in
            switch result {
            case .success(let taskListFromStorage):
                taskList = taskListFromStorage
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func showAlert(
        withTitle title: String,
        andMessage message: String,
        textFieldCompletion: ((UITextField) -> Void)?,
        saveButtonCompletion: @escaping(String) -> Void
    ) {
        let alert  = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let saveAction = UIAlertAction(
            title: "Save Task",
            style: .default
        ) { _ in
            guard let taskName = alert.textFields?.first?.text, !taskName.isEmpty else { return }
            saveButtonCompletion(taskName)
        }
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .destructive
        )
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField(configurationHandler: textFieldCompletion)
        present(alert, animated: true)
    }
    
    private func save(_ taskName: String) {
        storageManager.saveTask(withName: taskName) { [unowned self] result in
            switch result {
            case .success(let task):
                taskList.append(task)
                let indexPath = IndexPath(row: taskList.count - 1, section: 0)
                tableView.insertRows(at: [indexPath], with: .automatic)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        taskList.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let toDoTask = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = toDoTask.title
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            storageManager.deleteTask(taskList[indexPath.row]) { [unowned self] result in
                switch result {
                case .success(_):
                    taskList.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let task = taskList[indexPath.row]
        showAlert(
            withTitle: "Edit Task",
            andMessage: "What do you want to do") { textField in
                textField.text = task.title
            } saveButtonCompletion: { [unowned self] newName in
                storageManager.updateTask(
                    task,
                    withNewName: newName) { result in
                        switch result {
                        case .success(_):
                            tableView.reloadData()
                        case .failure(let error):
                            print(error)
                        }
                    }
            }
    }
}

// MARK: - Setup UI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        //Navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        
        navBarAppearance.backgroundColor = .milkBlue
        
        navBarAppearance.titleTextAttributes = [ .foregroundColor: UIColor.white ]
        navBarAppearance.largeTitleTextAttributes = [ .foregroundColor: UIColor.white ]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        //Add button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        navigationController?.navigationBar.tintColor = .white
    }
}
