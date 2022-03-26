//
//  ViewController.swift
//  Toddly
//
//  Created by Locomoviles on 3/19/22.
//

import UIKit
import Combine
import TodoWebServices

class TodoViewController: UIViewController {
    var todo: Todo?
    var position: Int?
    var api: TodoAPI!
    var cancellable: AnyCancellable!
    
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var save: UIBarButtonItem!
    @IBOutlet weak var completedSwitch: UISwitch!
    
    init?(coder: NSCoder, todo: Todo?, position: Int?, api: TodoAPI) {
        self.todo = todo
        self.position = position
        self.api = api
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    func updateView() {
        guard let todo = todo else {
            return
        }
        
        self.titleTextView.text = todo.title
        self.completedSwitch.isOn = todo.completed
    }
    
    @IBAction func submitAction(_ sender: UIBarButtonItem) {
        guard let title = titleTextView.text, !title.isEmpty else {
            return
        }
        
        if var todo = todo, !todo.id.isEmpty {
            todo.title = title
            todo.completed = completedSwitch.isOn
            edit(todo: todo)
        } else {
            let newTodo = Todo(title: title, completed: completedSwitch.isOn, order: position!)
            add(todo: newTodo)
        }
    }
    
    func edit(todo: Todo) {
        do {
            let publisher: AnyPublisher<Todo?, Error> = try api.edit(todo: todo)
            
            cancellable = publisher.sink { completion in
                    switch completion {
                    case .finished:
                        self.performSegue(withIdentifier: "unwindToTodoList", sender: self)
                    case .failure(let error):
                        self.showAlert(message: error.localizedDescription)
                    }
                } receiveValue: { _ in }
        } catch {
            self.showAlert(message: error.localizedDescription)
        }
    }
    
    func add(todo: Todo) {
        do {
            let publisher: AnyPublisher<Todo?, Error> = try api.add(todo: todo)
            
            cancellable = publisher.sink { completion in
                    switch completion {
                    case .finished:
                        self.performSegue(withIdentifier: "unwindToTodoList", sender: self)
                    case .failure(let error):
                        self.showAlert(message: error.localizedDescription)
                    }
                } receiveValue: { _ in }
        } catch {
            self.showAlert(message: error.localizedDescription)
        }
    }
}
