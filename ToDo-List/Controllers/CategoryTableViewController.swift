//
//  CategoryTableViewController.swift
//  ToDo-List
//
//  Created by Elmira on 16.02.21.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    
    var categoryList = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
       // print(categoryList[0].name!)
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add category", style: .default) { (action) in
            let newItem = Category(context: self.context)
            newItem.name = textField.text!
            self.categoryList.append(newItem)
            self.saveItems()
            self.tableView.reloadData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Data manipulation methods
    func saveItems(){
        do {
            try context.save()
        } catch {
            print(error)
        }
        self.tableView.reloadData()
    }
    
    func loadItems(){
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        do {
            categoryList = try context.fetch(request)
        } catch {
            print(error)
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let item = categoryList[indexPath.row]
        cell.textLabel?.text = item.name
        return cell
    }
    
    
//MARK: - TableView Delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryList[indexPath.row]
        }
    }
}
