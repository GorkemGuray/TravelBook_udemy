//
//  ListViewController.swift
//  TravelBook
//
//  Created by Görkem Güray on 31.08.2023.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    //var fetchedDataForList = [NSManagedObject]()
    var placeTitles = [String] ()
    var placeSubtitles = [String] ()
    var placeId = [UUID] ()
    
    var chosenTitle = ""
    var chosenId : UUID?


    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))

        tableView.delegate = self
        tableView.dataSource = self
        
        getDataFromPlaces()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getDataFromPlaces), name: NSNotification.Name("newPlace"), object: nil)
    }
    
    @objc func addButtonClicked() {
        chosenTitle = ""
        performSegue(withIdentifier: "toViewController", sender: nil)
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        var content = cell.defaultContentConfiguration()
        content.text = placeTitles[indexPath.row]
        content.secondaryText = placeSubtitles[indexPath.row]
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeTitles.count
    }
    
    @objc func getDataFromPlaces() {
        
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            if results.count > 0 {
                
                placeTitles.removeAll(keepingCapacity: false)
                placeSubtitles.removeAll(keepingCapacity: false)
                placeId.removeAll(keepingCapacity: false)
                
                for result in results as! [NSManagedObject] {
                    
                    if let title = result.value(forKey: "title") as? String {
                        placeTitles.append(title)
                    }
                    
                    if let subtitle = result.value(forKey: "subtitle") as? String {
                        placeSubtitles.append(subtitle)
                    }
                    
                    if let id = result.value(forKey: "id") as? UUID {
                        placeId.append(id)
                    }
                    
                    tableView.reloadData()
                }
                
            } else {
                print("gösterilecek veri yok.")
            }
            
            
                    
            
        } catch {
            
            print("Veri çekilirken hata oluştu.")

            
        } //CATCH
        
    } //FUNC SONU
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenTitle = placeTitles[indexPath.row]
        chosenId = placeId[indexPath.row]
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toViewController" {
            
            let destinationVC = segue.destination as! ViewController
            destinationVC.selectedTitle = chosenTitle
            destinationVC.selectedID = chosenId
            
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
