//
//  ViewController.swift
//  AlisverisListesi
//
//  Created by ertugrul on 26.07.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var nameArray = [String]()
    var idArray = [UUID]()
    
    var nameofshippedproduct = ""
    var idofshippedproduct : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(artiTiklandi))
        
        getData()

    }
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "veriGirildi"), object: nil)
    }

    @objc func artiTiklandi() {
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    
    @objc func getData(){
        
        // BAŞLANGIÇTA HEPSİNİ SİLERİZ ÇÜNKÜ 2 KEZ YAZDIRMAYA BAŞLAR.
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        
        let appDelagate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelagate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
           let sonuclar = try context.fetch(fetchRequest)
            if sonuclar.count > 0{        // İLK BAŞLAGIGINDA VERİ YOKSA ONU NSManagedObject'A DÖNÜŞTÜRMEK SIKINTI YAPAR.
            for sonuc in sonuclar as![NSManagedObject]{
                if let isim = sonuc.value(forKey: "isim") as? String{
                    nameArray.append(isim)
                }
                if let id = sonuc.value(forKey: "id") as? UUID {
                    idArray.append(id)
                    
                }
                tableView.reloadData()
                
            }
            }
        }catch{
            print("Hata Var..")
        }
    }
                                   //  TABLEVIEW FUNCTİONS
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        nameofshippedproduct = nameArray[indexPath.row]
        idofshippedproduct = idArray[indexPath.row]
        
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete{
            let appDeligate = UIApplication.shared.delegate as! AppDelegate
            let context = appDeligate.persistentContainer.viewContext
            let fechRecuast = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
            var uuıdString = idArray[indexPath.row].uuidString
            fechRecuast.predicate = NSPredicate(format: "id = %@", uuıdString)
            
            do{
                var sonuclar = try context.fetch(fechRecuast)
                if sonuclar.count > 0{
                    for sonuc in sonuclar as! [NSManagedObject]{
                        if let id = sonuc.value(forKey: "id") as? UUID{
                            if id == idArray[indexPath.row] {
                                context.delete(sonuc)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                
                                self.tableView.reloadData()
                                
                                do{
                                    try context.save()
                                }catch{
                                    
                                }
                            }
                            break
                        }
                          
                    }
                }
            }catch{
                
            }
        
            
            
            
           // isimDizi.remove(at: indexPath.row)
            //tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC"{
            let destination = segue.destination as! DetailsViewController
            destination.gelenUrunIsmi = nameofshippedproduct
            destination.gelenUrunUudi = idofshippedproduct
        }
    }

}

