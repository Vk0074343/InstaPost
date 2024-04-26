//
//  AddPostsVc.swift
//  InstaPost
//
//  Created by Vaibhav Khatri on 25/04/24.
//

import UIKit
import PhotosUI
import FirebaseStorage
import FirebaseFirestore

class SelctedImageListCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AddPostsVc: UIViewController, PHPickerViewControllerDelegate {
    
    @IBOutlet weak var textFieldUserId: UITextField!
    @IBOutlet weak var collectionViewPickedImages: UICollectionView!
    @IBOutlet weak var textViewDescription: UITextView!
    
    let storage = Storage.storage()
    let db = Firestore.firestore()
    var arrayOfImageURL:[String] = []
    var selectedImages: [UIImage] = []
    let placeholderLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewPickedImages.register(SelctedImageListCell.self, forCellWithReuseIdentifier: "SelctedImageListCell")
        self.setTheme()
    }
    
    func setTheme(){
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 50, height: 50) // Set fixed size for the cells
        layout.minimumInteritemSpacing = 0 // Adjust as needed
        layout.minimumLineSpacing = 0 // Adjust as needed
        collectionViewPickedImages.collectionViewLayout = layout
        
        collectionViewPickedImages.layer.cornerRadius = 10
        collectionViewPickedImages.layer.borderWidth = 0.5
        collectionViewPickedImages.layer.borderColor = UIColor.lightGray.cgColor
        
        textViewDescription.layer.cornerRadius = 10
        textViewDescription.layer.borderWidth = 0.5
        textViewDescription.layer.borderColor = UIColor.lightGray.cgColor
        
        textViewDescription.delegate = self
        
        placeholderLabel.text = StringConstant.enter_description
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.textAlignment = .left
        placeholderLabel.font = UIFont.systemFont(ofSize: 14)
        placeholderLabel.numberOfLines = 0
        textViewDescription.addSubview(placeholderLabel)
        
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: textViewDescription.topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: textViewDescription.leadingAnchor, constant: 5),
            placeholderLabel.trailingAnchor.constraint(equalTo: textViewDescription.trailingAnchor, constant: -5),
        ])
        
        placeholderLabel.isHidden = !textViewDescription.text.isEmpty
    }
    
    @IBAction func buttonAddPost(_ sender: UIButton) {
        if textFieldUserId.text?.isBlank() ?? true{
            showDefaultAlertView(viewController: self, title: AppName, message: StringConstant.enter_username)
        } else if textViewDescription.text?.isBlank() ?? true{
            showDefaultAlertView(viewController: self, title: AppName, message: StringConstant.enter_description)
        } else if self.selectedImages.count == 0{
            showDefaultAlertView(viewController: self, title: AppName, message: StringConstant.select_images)
        }else{
            sender.isEnabled = false
            self.uploadImages(self.selectedImages) { success in
                sender.isEnabled = true
                if success {
                    showDefaultAlertView(viewController: self, title: AppName, message: StringConstant.post_uploaded_successfully)
                } else {
                    showDefaultAlertView(viewController: self, title: AppName, message: StringConstant.post_upload_failed)
                }
            }
        }
    }
}

//MARK: - CollectionView Delegate
extension AddPostsVc: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        selectedImages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelctedImageListCell", for: indexPath) as! SelctedImageListCell
        
        if indexPath.item == 0 {
            cell.imageView.image = .add
        } else {
            let imageIndex = indexPath.item - 1
            cell.imageView.image = selectedImages[imageIndex]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            if #available(iOS 14.0, *) {
                var configuration = PHPickerConfiguration()
                configuration.selectionLimit = 0 // Set to 0 for unlimited selection
                let picker = PHPickerViewController(configuration: configuration)
                picker.delegate = self
                present(picker, animated: true)
            } else {
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let topInset: CGFloat = 5 // Adjust as needed
        let bottomInset: CGFloat = 5 // Adjust as needed
        return UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
    }
}

//MARK: - textView Delegate
extension AddPostsVc: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textViewDescription.text.isEmpty
    }
}

//MARK: - PickerMethod
extension AddPostsVc{
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let image = image as? UIImage {
                    self.selectedImages.append(image)
                    if (self.selectedImages.count == results.count) {
                        DispatchQueue.main.async {
                            self.collectionViewPickedImages.reloadData()
                        }
                    }
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
        
        print("\(results.count)")
    }
}

//MARK: - Upload Image and Update Data on Firestore
extension  AddPostsVc{
    func uploadImages(_ images: [UIImage], completion: @escaping (Bool) -> Void) {
        let storageRef = storage.reference()
        
        for (index, image) in images.enumerated() {
            let resizedImage = resizeImage(image, targetSize: CGSize(width: 1000, height: 1000))
            
            let imageRef = storageRef.child("images/image-\(UUID().uuidString).jpg")
            guard let imageData = resizedImage.jpegData(compressionQuality: 0.6) else {
                print("Error converting image to data.")
                return
            }
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let uploadTask = imageRef.putData(imageData, metadata: metadata) { (metadata, error) in
                guard metadata != nil else {
                    return
                }
                imageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        print("Error retrieving download URL: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    self.arrayOfImageURL.append(downloadURL.absoluteString)
                    if (images.count == self.arrayOfImageURL.count) {
                        self.uploadData()
                    }
                }
            }
            
            uploadTask.observe(.progress) { snapshot in
                _ = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            }
            
            uploadTask.observe(.success) { snapshot in
                completion(true)
            }
            
            uploadTask.observe(.failure) { snapshot in
                if snapshot.error != nil {
                    completion(false)
                }
            }
        }
    }
    
    func uploadData(){
        let data: [String: Any] = [
            "imageUrls": self.arrayOfImageURL,
            "postCreationDate": Date(),
            "userId": self.textFieldUserId.text ?? "",
            "postDescription": self.textViewDescription.text ?? ""
        ]
        db.collection("posts").addDocument(data: data) { err in
            if let err = err {
                showDefaultAlertView(viewController: self, title: AppName, message: "Post upload failed, due to \(err.localizedDescription)")
            } else {
                self.textFieldUserId.text = ""
                self.textViewDescription.text = ""
                self.placeholderLabel.isHidden = false
                self.selectedImages.removeAll()
                DispatchQueue.main.async {
                    self.collectionViewPickedImages.reloadData()
                }
                self.view.endEditing(true)
            }
        }
    }
}
