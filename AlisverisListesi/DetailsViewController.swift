//
//  DetailsViewController.swift
//  AlisverisListesi
//
//  Created by ertugrul on 26.07.2022.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var isimTextField: UITextField!
    @IBOutlet weak var fiyatTextField: UITextField!
    @IBOutlet weak var bedenTextField: UITextField!
    
    @IBOutlet weak var kaydetButton: UIButton!  // !!!!
    
    var gelenUrunIsmi = ""
    var gelenUrunUudi : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if gelenUrunIsmi != ""{
            //Core Data seçilen ürün bilgilerini göster
            
            kaydetButton.isHidden = true
            
            if let gelenUrunUudi = gelenUrunUudi?.uuidString {    // Burda uudi yi Stringe ÇEVİRDİK KULLANDIK.
                
                let appDelagate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelagate.persistentContainer.viewContext
                let fechRecuest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
/**ÖNEMLİ**/    fechRecuest.predicate = NSPredicate(format: "id = %@", gelenUrunUudi)
                fechRecuest.returnsObjectsAsFaults = false
             
                do{
                    let sonuclar = try context.fetch(fechRecuest)
                    if sonuclar.count > 0{
                        for sonuc in sonuclar as! [NSManagedObject]{
                            
                            if let isim = sonuc.value(forKey: "isim") as? String{
                                isimTextField.text = isim
                            }
                            if let fiyat = sonuc.value(forKey: "fiyat") as? Int{
                                fiyatTextField.text = String(fiyat)
                            }
                            
                            if let beden = sonuc.value(forKey: "beden") as? String{
                                bedenTextField.text = beden
                            }
                            if let resim = sonuc.value(forKey: "gorsel") as? Data{
                                imageView.image = UIImage(data: resim)
                            }
                            
                        }
                                
                    }
                }catch{
                    
                }
            }
            
        }else{
            kaydetButton.isHidden = false
            kaydetButton.isEnabled = false
            
            isimTextField.text = ""
            fiyatTextField.text = ""
            bedenTextField.text = ""
            
            
            
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(kilavyeKapat))
        view.addGestureRecognizer(gestureRecognizer)

        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gorselSec))
        imageView.addGestureRecognizer(imageGestureRecognizer)

       
    }
    
    
    @objc func kilavyeKapat(){
        view.endEditing(true)
    }
    
    @objc func gorselSec() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.originalImage] as? UIImage
        
        kaydetButton.isEnabled = true
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func kaydetTiknadi(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let alisveris = NSEntityDescription.insertNewObject(forEntityName: "Alisveris", into: context)
        
        alisveris.setValue(isimTextField.text, forKey: "isim")
        alisveris.setValue(bedenTextField.text, forKey: "beden")
        alisveris.setValue(UUID(), forKey: "id")
        
        if let intFiyat = Int(fiyatTextField.text!){
            alisveris.setValue(intFiyat, forKey: "fiyat")
        }
        
        let newGorsel = imageView.image?.jpegData(compressionQuality: 0.5)
        alisveris.setValue(newGorsel, forKey: "gorsel")
        
        
        do{
            try context.save()
            print("kayıt edildi")
        }catch{
            print("Hata Oldu")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("veriGirildi"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    

}
