//
//  ViewController.swift
//  MilestoneProject4
//
//  Created by Дмитрий Головин on 18.04.2021.
//

import UIKit

class ViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var photos = [Photo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(addPhoto))
        
        title = "Milestone Project 4"
        
        let defaults = UserDefaults.standard
        
        if let savedPhotos = defaults.object(forKey: "photos") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                photos = try jsonDecoder.decode([Photo].self, from: savedPhotos)
            } catch {
                print("Fail 2")
            }
        }
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(photos) {
            UserDefaults.standard.set(savedData, forKey: "photos")
        } else {
            print("Fail")
        }
    }

    @objc func addPhoto() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }

    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        let photo = photos[indexPath.row]
        let path = getDocumentDirectory().appendingPathComponent(photo.image)
        cell.photo.image = UIImage(contentsOfFile: path.path)
        cell.caption.text = photo.caption
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        let ac = UIAlertController(title: "Add photo description?", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            self?.addDescription(photo: photo)
        }))
        
        present(ac, animated: true, completion: nil)
    }
    
    func addDescription(photo: Photo) {
        let ac = UIAlertController(title: "Adding desciprition", message: "Please, add the photo caption", preferredStyle: .alert)
        ac.addTextField(configurationHandler: nil)
        
        ac.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self, weak ac] _ in
            guard let text = ac?.textFields?.first?.text else { return }
            photo.caption = text
            self?.save()
            self?.tableView.reloadData()
        }))
        present(ac, animated: true, completion: nil)
        
    }
    
    
    // MARK: Image Picker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        let photo = Photo(caption: "Unknown description", image: imageName)
        photos.append(photo)
        save()
        tableView.reloadData()
        
        dismiss(animated: true, completion: nil)
    }
    
    func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
}

