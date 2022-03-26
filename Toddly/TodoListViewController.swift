//
//  TodoListTableViewController.swift
//  Toddly
//
//  Created by Locomoviles on 3/19/22.
//

import Combine
import UIKit
import TodoWebServices

class TodoListViewController: UITableViewController {
    var api = TodoAPI()
    var todos = [Todo]()
    var lastMoved: Todo!

    var cancellables = Set<AnyCancellable>()
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateList()
    }

    func bindRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(updateList), for: .valueChanged)
    }
    
    @objc
    func updateList() {
        let publisher: AnyPublisher<[Todo], Error> = api.fetch()

        publisher
            .sink { completion in
                if case .failure(let error) = completion {
                    self.showAlert(message: error.localizedDescription)
                }
                
                self.refreshControl?.endRefreshing()
                
            } receiveValue: { todos in
                self.reloadList(todos: todos)
            }
            .store(in: &cancellables)
    }

    func reloadList(todos: [Todo]) {
        self.todos.removeAll()
        self.todos.append(contentsOf: todos)
        self.tableView.reloadData()
        self.updateEdit()
    }
    
    func updateEdit() {
        editButton.isEnabled = todos.count > 0
        addButton.isEnabled = true
    }
    
    func updateRemote(startIndex: Int = 0) {
        let count = todos.count
        var todo = todos[startIndex]
        todo.order = startIndex

        let nextIndex = startIndex + 1

        try! api.edit(todo: todo)
            .sink(receiveCompletion: { _ in
                if nextIndex < count {
                    self.updateRemote(startIndex: startIndex + 1)
                } else {
                    self.updateList()
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        let todo = todos[indexPath.row]
        cell.textLabel?.text = todo.title
        cell.accessoryType = todo.completed ? .checkmark : .none
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let todo = todos[indexPath.row]
            do {
                try api.delete(todo: todo).sink { completion in
                    if case .failure(let error) = completion {
                        self.showAlert(message: error.localizedDescription)
                        self.updateList()
                    } else {
                        self.todos.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        self.updateEdit()
                    }
                } receiveValue: { _ in }
                    .store(in: &cancellables)
            } catch {
                self.showAlert(message: error.localizedDescription)
            }
        }
    }

    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        var toMoveItem = todos[fromIndexPath.row]
        toMoveItem.order = to.row

        lastMoved = toMoveItem

        todos.remove(at: fromIndexPath.row)
        todos.insert(toMoveItem, at: to.row)
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    @IBAction func editAction(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
        if editButton.title == "Edit" {
            editButton.title = "Done"
            addButton.isEnabled = false
        } else {
            editButton.title = "Edit"
            addButton.isEnabled = true

            updateRemote()
        }
    }

    // MARK: Segue actions
    @IBSegueAction func addSegueAction(_ coder: NSCoder, sender: Any?) -> TodoViewController? {
        return TodoViewController(coder: coder, todo: nil, position: todos.count, api: api)
    }

    @IBSegueAction func editSegueAction(_ coder: NSCoder, sender: Any?) -> TodoViewController? {
        let todoToEdit: Todo?
        if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            todoToEdit = todos[indexPath.row]
        } else {
            todoToEdit = nil
        }
        return TodoViewController(coder: coder, todo: todoToEdit, position: nil, api: api)
    }

    @IBAction func unwindToTodoList(_ segue: UIStoryboardSegue) {}
}
