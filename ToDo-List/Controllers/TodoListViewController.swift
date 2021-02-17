//
//  ViewController.swift
//  ToDo-List
//
//  Created by Elmira on 15.02.21.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var elements = [TodoListItem]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedCategory: Category? { //it's going to be nil until we can set it
        didSet{ //everything that's between these curly braces is going to happen as soon as selected category gets set with a value. didSet to specify what should happen when a variable gets set with a new value.
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask) //where sqlite is located
        // print(dataFilePath) //not documents, but library(last one)->application support
        //searchBar.delegate = self
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add action", style: .default) { (action) in
            let newItem = TodoListItem(context: self.context) //CREATE DATA
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.elements.append(newItem)
            self.saveItems()
            self.tableView.reloadData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems (){ //we need to commit our context to permanent storage inside our persistentContainer.
        do {
            try context.save()  //that transfers what's currently inside our staging area to our permanent data stores.
        } catch {
            print(error)
        }
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<TodoListItem> = TodoListItem.fetchRequest(), predicate: NSPredicate? = nil) {//READ DATA
        
        //NSFetchRequest is going to fetch results in the form of TodoListItem:
        //let request: NSFetchRequest<TodoListItem> = TodoListItem.fetchRequest()
        //as always, our application have to speak to the context before we can do anything with our persistent container.
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }

        do{
           elements = try context.fetch(request)
        } catch {
            print(error)
        }
        tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let item = elements[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        elements[indexPath.row].done = !elements[indexPath.row].done //changes
        //context.delete(elements[indexPath.row]) // DELETE DATA
        //elements.remove(at: indexPath.row)
        saveItems() //commit those changes by using the saveItem's method which simply commits the current state of the context
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }

}

//EXTENSION:

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<TodoListItem> = TodoListItem.fetchRequest()
        
        // in order to query objects using Core Data, we need to use something called an NSPredicate.
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
}
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
            //DispatchQueue is that manager who assigns these projects to different threads. And we're going to ask it to grab us the main thread. while background task are happening, we need to grab the main queue so that we can dismiss even if background tasks are still being completed.
                searchBar.resignFirstResponder()
            }
        }
    }
}





