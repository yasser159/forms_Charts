//
//  ViewController.swift
//  forms_Charts
//
//  Created by Yasser Hajlaoui on 7/6/22.
//

import UIKit
import RealmSwift
import SwipeCellKit

class VC_Box_ListScreen: UIViewController{
    
    let realm = try! Realm()
    var boxes: Results<Box>?   // Previously toDoItems
    var myIndexPath: IndexPath?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var tableViewMain: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        searchBar.delegate = self
        
        //print(Realm.Configuration.defaultConfiguration.fileURL!)
        loadBoxes()
        tableViewMain.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadBoxes), name: NSNotification.Name(rawValue: "refresh_BoxListScreen_Tableview"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        if(!appDelegate.hasAlreadyLaunched){
//            //set hasAlreadyLaunched to false
//            appDelegate.sethasAlreadyLaunched()
//            //display user agreement license
//            //print("App Running for the first time") // load default items to this tableview
//            loadDefaultAccounts()
//        }
        
        restoreBrightness()
    }
    
    func loadDefaultAccounts(){
            self.createAccount(myTitle: "Instagram", myImage: #imageLiteral(resourceName: "instagram_bw"))
            self.createAccount(myTitle: "Linkedin",  myImage: #imageLiteral(resourceName: "linkedin_bw"))
            self.createAccount(myTitle: "Facebook",  myImage: #imageLiteral(resourceName: "Facebook_bw"))
            self.createAccount(myTitle: "Gym",       myImage: #imageLiteral(resourceName: "Gym_icon"))

        self.tableViewMain.reloadData()
        
    }
    
    func createAccount(myTitle: String, myImage: UIImage){
        var imageName = ""
        let newBox = Box()
        
        imageName = myTitle
        
        newBox.BoxInit(imageName: imageName , title: myTitle)

        imageToDisk(imageName, myImage)       //Saving Image to disk
        save(box: newBox)
    }
    
    @objc func loadBoxes() {
        
        boxes = realm.objects(Box.self)
        tableViewMain.reloadData()
    }

    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    @IBAction func btn_AddNewBox(_ sender: Any) {

        print("add button tapped")

        performSegue(withIdentifier: "goToAddBox", sender: self)
}
    

    
    
    
    //Realm Save 💾 🗄 📂 🗂
    func save(box: Box){
                
        do {
            try realm.write {
                realm.add(box)
            }
        } catch {
            print("Error saving box \(error)")
        }
        
    }
    

    

//    //MARK: - Delete Data From Swipe
// ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌
// ❌ Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete  ❌
// ❌ Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete  ❌
// ❌ Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete  ❌
// ❌ Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete  ❌
// ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌
    
     func deleteBox(at indexPath: IndexPath) {
         
         if let boxForDeletion = self.boxes? [indexPath.row]{
             
         let confirmDeleteAlert = UIAlertController(title: "", message: "Confirm deletion of account " + boxForDeletion.title + " and all of its contents?" , preferredStyle: UIAlertController.Style.alert)

         confirmDeleteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in

             // 01 Delete the Images of the Box Items
             deleteObjectImages(boxForDeletion)

             
             // 01.1 Delete the Box Items (Multipe Objects)
             for item in boxForDeletion.items {
                 
                 do{
                     try self.realm.write {
                         self.realm.delete(item)
                     }
                 } catch {
                    print("Error deleting Box Item, \(error)")
                 }
                 
             }
             
             
             
             // Delete the Box
                    do{
                        try self.realm.write {
                            self.realm.delete(boxForDeletion)
                        }
                    } catch {
                       print("Error deleting category, \(error)")
                    }
                    self.tableViewMain.reloadData()
                
           }))//Confirm Delete
         
         confirmDeleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in /*Cancel Logic*/ }))
         present(confirmDeleteAlert, animated: true, completion: nil)
         
         
         }// if let bottom
         
     }
    
    func editBox(at indexPath: IndexPath){
        
        myIndexPath = indexPath  //⚙️⛔️ because the mainview selected cell index path wont work, work arround
                
        performSegue(withIdentifier: "goToEditBox", sender: self)
        
    }
    
    
    //MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("Account Selected: ", boxes![indexPath.row].title)
        
        performSegue(withIdentifier: "goToItemsVC", sender: self)
        //tableViewMain.deselectRow(at: indexPath, animated: true)
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        print("Prepare Segue")
        
        let segueID = segue.identifier
        
        switch segueID {
            
            case "goToAddBox": // + + +
                _ = segue.destination as! VC_Add_Box
            
            case "goToEditBox": // ✏️ ✏️ ✏️

            let destinationVC  = segue.destination as! VC_Edit_Box
            
            if let indexPath = myIndexPath {
                let myBox = boxes?[indexPath.row]
                destinationVC.currentBox = myBox
            }
            
            
            
        case "goToItemsVC":
            print("Pretend to go to vc item list screen")
//                let destinationVC  = segue.destination as! VC_Item_ListScreen
//
//                //Get index Path
//                if let indexPath = tableViewMain.indexPathForSelectedRow {
//                    destinationVC.selectedBox = boxes?[indexPath.row]
//                    tableViewMain.deselectRow(at: indexPath, animated: true)
//                }
            

            default://_______________________________________
                print("No Segue was sent")
            }
    }
    
} // end VC

extension VC_Box_ListScreen: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return boxes?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let box = boxes![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "BoxCell") as! BoxCell
        
        
        cell.delegate = self  //added today
        cell.setBox(box: box)
        
        return cell
    }
}



//MARK: - SwipeTableViewCellDelegate
extension VC_Box_ListScreen: SwipeTableViewCellDelegate {
    
    //
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath:
         IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        //let dataItem = boxes![indexPath.row] as Box
        //let cell = tableView.cellForRow(at: indexPath) as! UITableViewCell
        
        
        switch orientation {
        case .left:
            
            
            //  ✏️ ✏️ ✏️ ✏️ ✏️ ✏️ ✏️ ✏️ ✏️ ✏️ ✏️ ✏️ ✏️ ✏️ ✏️ ✏️ ✏️ ✏️ ✏️ ✏️
            let editAction = SwipeAction(style: .destructive, title: nil, handler:{
                action, indexPath in
                
                self.editBox(at: indexPath)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
                    tableView.reloadData()
                })
            })
            
            editAction.title = "Edit" // customize the action appearance
            editAction.image = UIImage(systemName: "highlighter")
            editAction.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
            
            //__________________________________________________________________________
            
            
            
            //new stuff here
            let _: (UIAlertAction) -> Void = { (action: UIAlertAction) in
                //not sure about this
                //cell.hideSwipe(animated: true) //????????????????????

                if let selectedTitle = action.title {
                    print("selectedTitle: \(selectedTitle)")
                    let alertController = UIAlertController(title: selectedTitle,
                    message: "Some Message", preferredStyle: .alert)

                    alertController.addAction(UIAlertAction(title: "Option Alert Message", style: .cancel, handler: nil))

                    self.present(alertController, animated: true, completion: nil)
                }
            }            //MoreItems Action
            
    
        return  [editAction]

            
            
        case .right:
            
            
            // ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌
            let deleteAction = SwipeAction(style: .destructive, title: nil, handler:{
                action, indexPath in
                //print("Run Delete Action Code")
                self.deleteBox(at: indexPath)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
                    //self.boxes.remove(at: indexPath.row)   // handle action by updating model with deletion

                    tableView.reloadData()
                })
            })
            
            deleteAction.title = "Delete" // customize the action appearance
            deleteAction.image = UIImage(systemName: "trash.fill")
            deleteAction.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
            
        return [deleteAction]
        }
        
    }
    
    //
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath:
         IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        
        var options = SwipeOptions()
        //
        options.expansionStyle = .selection
        options.transitionStyle = .drag
        
        return options
    }
    
}



//
////Mark: - Searchbar delegate methods
extension VC_Box_ListScreen: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
                boxes = boxes?.filter("title CONTAINS[cd] %@", searchText).sorted(byKeyPath: "title", ascending: true)
                tableViewMain.reloadData()
        
                if searchBar.text?.count == 0 {
                    loadBoxes()
                }
    }
}
