//
//  SignUpViewController.swift
//  Volunteerium
//
//  Created by Phillips, Ryan L on 3/3/17.
//  Copyright © 2017 Phillips, Ryan L. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var fName: UITextField!
    @IBOutlet weak var lName: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPW: UITextField!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var nextBtn: UIButton!
    
    let picker = UIImagePickerController()
    
    var userStorage: FIRStorageReference!
    var ref: FIRDatabaseReference!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        let storage = FIRStorage.storage().reference(forURL: "gs://volunteerium-f61e4.appspot.com")
        
        ref = FIRDatabase.database().reference()
        
        userStorage = storage.child("users")
        
    }

    @IBAction func selectImage(_ sender: Any) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            self.photoImage.image = image
            nextBtn.isHidden = false
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func isPressed(_ sender: Any) {
        guard fName.text != "", lName.text != "", passwordField.text != "", confirmPW.text != "" else {
            print("Some Fields are empty")
            return
        }
        
        if passwordField.text == confirmPW.text{
            FIRAuth.auth()?.createUser(withEmail: emailField.text!, password: passwordField.text!, completion:{
            (user, error) in
            if let error = error{
                print(error.localizedDescription)
                
            }
            
                if let user = user {
                    let changeRequest = FIRAuth.auth()!.currentUser!.profileChangeRequest()
                    changeRequest.displayName = self.fName.text!
                    changeRequest.commitChanges(completion: nil)
                
                    let imageRef = self.userStorage.child("\(user.uid).jpg")
                
                    let data = UIImageJPEGRepresentation(self.photoImage.image!, 0.5)
                
                    let uploadTask = imageRef.put(data!, metadata: nil, completion:{ (metadata, err) in
                    if err != nil{
                        print(err!.localizedDescription)
                    }
                    
                        imageRef.downloadURL(completion: {(url, er) in
                            if er != nil{
                                print(er!.localizedDescription)
                            }
                        
                            if let url = url{
                                let userInfo: [String: Any] = ["uid": user.uid, "FirstName" : self.fName.text!, "LastName": self.lName.text!, "urlToImage": url.absoluteString]
                            
                                self.ref.child("users").child(user.uid).setValue(userInfo)
                            
                                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersVC")
                            
                                self.present(vc, animated: true, completion: nil)
                            }
                        })
                    })
                
                    uploadTask.resume()
                }
            })
            
        } else {
            print("passwords do not match")
        }

    }
    
}
