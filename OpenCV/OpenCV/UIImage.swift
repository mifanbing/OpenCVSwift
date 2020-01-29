import UIKit

extension UIImage {
    func rotate(radians: CGFloat) -> UIImage? {
        //var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: radians)).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        //newSize.width = floor(newSize.width)
        //newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        // Move origin to middle
        context.translateBy(x: size.width/2, y: size.height/2)
        // Rotate around middle
        context.rotate(by: radians)
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func resizeImage(targetSize: CGSize) -> UIImage {
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func rotateImage(angle:CGFloat) -> UIImage? {
        let ciImage = CIImage(image: self)
        let filter = CIFilter(name: "CIAffineTransform")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setDefaults()
        let newAngle = angle * CGFloat(-1)
        var transform = CATransform3DIdentity
        transform = CATransform3DRotate(transform, CGFloat(newAngle), 0, 0, 1)
        let affineTransform = CATransform3DGetAffineTransform(transform)
        filter?.setValue(NSValue(cgAffineTransform: affineTransform), forKey: "inputTransform")
        let context = CIContext(options: [CIContextOption.useSoftwareRenderer:true])
        let outputImage = filter?.outputImage
        let cgImage = context.createCGImage(outputImage!, from: (outputImage?.extent)!)
        let result = UIImage(cgImage: cgImage!)
        
        return result
    }
}

