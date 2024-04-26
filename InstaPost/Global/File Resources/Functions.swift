//
//  Functions.swift
//  InstaPost
//
//  Created by Vaibhav Khatri on 26/04/24.
//

import Foundation
import UIKit

func showDefaultAlertView(viewController: UIViewController,title : String,message : String,needToLocalize : Bool = true) {
    let strTitle = title
   
    let alertMessage = UIAlertController.init(title: strTitle, message: message, preferredStyle: .alert)
    
    let alertYESAction = UIAlertAction.init(title: "OK", style: .default, handler: { (action : UIAlertAction) in
        alertMessage.dismiss(animated: true, completion:nil)
    })
    
    alertMessage.addAction(alertYESAction)
    DispatchQueue.main.async {
    viewController.present(alertMessage, animated: true, completion: nil)
    }
}

func timeAgoString(from dateString: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    guard let date = dateFormatter.date(from: dateString) else {
        return "Invalid date format"
    }
    
    let calendar = Calendar.current
    let now = Date()
    
    let components = calendar.dateComponents([.second, .minute, .hour, .day, .weekOfYear, .month, .year], from: date, to: now)
    
    if let year = components.year, year > 0 {
        return "\(year) year\(year == 1 ? "" : "s") ago"
    }
    if let month = components.month, month > 0 {
        return "\(month) month\(month == 1 ? "" : "s") ago"
    }
    if let week = components.weekOfYear, week > 0 {
        return "\(week) week\(week == 1 ? "" : "s") ago"
    }
    if let day = components.day, day > 0 {
        return "\(day) day\(day == 1 ? "" : "s") ago"
    }
    if let hour = components.hour, hour > 0 {
        return "\(hour) hr\(hour == 1 ? "" : "s") ago"
    }
    if let minute = components.minute, minute > 0 {
        return "\(minute) min\(minute == 1 ? "" : "s") ago"
    }
    if let second = components.second, second > 0 {
        return "\(second) sec\(second == 1 ? "" : "s") ago"
    }
    
    return "Just now"
}

func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size

    let widthRatio  = targetSize.width / size.width
    let heightRatio = targetSize.height / size.height

    let scaleFactor = min(widthRatio, heightRatio)

    let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)

    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    defer { UIGraphicsEndImageContext() }

    image.draw(in: CGRect(origin: .zero, size: newSize))

    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    return newImage ?? UIImage()
}
