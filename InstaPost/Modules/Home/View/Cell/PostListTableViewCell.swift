//
//  PostListTableViewCell.swift
//  InstaPost
//
//  Created by Vaibhav Khatri on 24/04/24.
//

import UIKit
import SDWebImage

class PostListTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionViewImage: UICollectionView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelCreatinDate: UILabel!
    
    var arrayOfImages: [String] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionViewImage.register(UINib(nibName: "PostImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PostImageCollectionViewCell")

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

extension PostListTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.arrayOfImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostImageCollectionViewCell", for: indexPath) as? PostImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        if let imageUrl = URL(string: self.arrayOfImages[indexPath.row]) {
            // Use SDWebImage to load the image asynchronously and set it to the imageView
            cell.imageViewPost.sd_setImage(with: imageUrl, placeholderImage: .strokedCheckmark, completed: { (image, error, cacheType, imageUrl) in
                cell.imageViewPost.layer.cornerRadius = 10
                cell.imageViewPost.clipsToBounds = true
            })
        } else {
            print("Invalid URL")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width:(collectionView.frame.size.width), height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 5, right: 5)
    }
}
