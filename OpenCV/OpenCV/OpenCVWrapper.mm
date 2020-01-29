#import "OpenCVWrapper.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import <opencv2/opencv.hpp>

@implementation OpenCVWrapper

+ (NSString *)openCVVersionString {
    
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

+ (UIImage *)cvInpaint:(UIImage *)inputImage maskImage:(UIImage *) mask {
    CGFloat cols = inputImage.size.width;
    CGFloat rows = inputImage.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4);
    cv::Mat inputImageCV = [OpenCVWrapper cvMatFromUIImage:inputImage];
    cv::Mat inputImageCV3C(rows, cols, CV_8UC3);
    cv::cvtColor(inputImageCV, inputImageCV3C, cv::COLOR_RGBA2RGB);
    cv::Mat inputImageCVResized(rows, cols, CV_8UC3);
    cv::resize(inputImageCV3C, inputImageCVResized, cv::Size(cols, rows));
    
    cv::Mat maskImageCV = [OpenCVWrapper cvMatFromUIImage:mask];
    cv::Mat maskImageCV3C(rows, cols, CV_8UC1);
    cv::Mat maskImageCVResized(rows, cols, CV_8UC1);
    cv::resize(maskImageCV3C, maskImageCVResized, cv::Size(cols, rows));
    
    cv::inpaint(inputImageCVResized, maskImageCVResized, cvMat, 10, cv::INPAINT_TELEA);
    
    //return [OpenCVWrapper UIImageFromCVMat:inputImageCV3C];
    return [OpenCVWrapper UIImageFromCVMat:cvMat];
}

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
  CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
  CGFloat cols = image.size.width;
  CGFloat rows = image.size.height;

  cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)

  CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                 cols,                       // Width of bitmap
                                                 rows,                       // Height of bitmap
                                                 8,                          // Bits per component
                                                 cvMat.step[0],              // Bytes per row
                                                 colorSpace,                 // Colorspace
                                                 kCGImageAlphaNoneSkipLast |
                                                 kCGBitmapByteOrderDefault); // Bitmap info flags

  CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
  CGContextRelease(contextRef);

  return cvMat;

  return cvMat;
}


+ (cv::Mat)cvMaskMatFromUIImage:(UIImage *)image
{
    //kp, des = self.surf.detectAndCompute(gray, None)
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cols,              // Bytes per row
                                                    NULL,                 // Colorspace
                                                    kCGImageAlphaOnly); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

+(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                              //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

@end
