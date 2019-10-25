//
//  ReceiptsTableViewController.swift
//  ReceiptTracker
//
//  Created by macbook on 10/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import CoreData
import Cloudinary

enum SortingType: String, CaseIterable {
    // TODO: match the core data model names
    case merchant = "merchant"
    case category = "category"
    case amount = "amountSpent"
    case date = "dateOfTransaction"
}

class ReceiptsTableViewController: UITableViewController {
    
    var receiptController = ReceiptController()
    var logInController = LogInController()
    
    @IBOutlet weak var sortingTypeSegmentedControl: UISegmentedControl!
    
    var sortType: SortingType = .merchant
    //    var receipts: [ReceiptRepresentation] = []
    
    
    lazy var fetchedResultsController: NSFetchedResultsController<Receipt> = {
        
        let fetchRequest: NSFetchRequest<Receipt> = Receipt.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: sortType.rawValue, ascending: true),
            NSSortDescriptor(key: "dateOfTransaction", ascending: true)
        ]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.mainContext, sectionNameKeyPath: sortType.rawValue, cacheName: nil)
        
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch {
            fatalError("Error performing fetch for frc: \(error)")
        }
        return frc
    }()
    @IBAction func sortTypeValueChanged(_ sender: UISegmentedControl) {
        sortType = SortingType.allCases[sender.selectedSegmentIndex]
        tableView.reloadData()
        tableView.reloadSectionIndexTitles()
    }
    
    
    
    
    // MARK: - Segue to Login page
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if logInController.bearer == nil {
            performSegue(withIdentifier: "LoginSegue", sender: self)
            
        } else {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiptCell", for: indexPath) as? ReceiptTableViewCell else { return UITableViewCell() }
        cell.receipt = fetchedResultsController.object(at: indexPath)
        cell.sortType = sortType
        
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            receiptController.deleteReceipt(receipt: fetchedResultsController.object(at: indexPath), context: CoreDataStack.shared.mainContext)
            
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sortType != .amount {
            return fetchedResultsController.sections?[section].name
        } else {
            return nil
        }
    }
    
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginSegue" {
            if let loginVC = segue.destination as? ReceiptLogInViewController {
                loginVC.logInController = logInController
                loginVC.receiptController = receiptController
            }
        } else if segue.identifier == "AddReceiptSegue" {
            if let detailVC = segue.destination as? ReceiptDetailViewController {
                detailVC.receiptController = receiptController
                detailVC.logInController = logInController
            }
        } else if segue.identifier == "ShowDetailsSegue" {
            if let detailVC = segue.destination as? ReceiptDetailViewController,
                let indexPath = tableView.indexPathForSelectedRow {
                detailVC.receiptController = self.receiptController
                detailVC.receipt = fetchedResultsController.object(at: indexPath)
                detailVC.logInController = logInController
            }
        }
    }
}

extension ReceiptsTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            tableView.moveRow(at: indexPath, to: newIndexPath)
            
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
        @unknown default:
            fatalError()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .automatic)
        default:
            return
        }
        
    }
}
