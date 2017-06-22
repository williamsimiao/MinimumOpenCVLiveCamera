//
//  FrameProcessor.m
//  MinimumOpenCVLiveCamera
//
//  Created by Akira Iwaya on 2015/11/05.
//  Copyright © 2015年 akira108. All rights reserved.
//

#import "FrameProcessor.h"

using namespace std;
using namespace cv;

@implementation FrameProcessor
//Path to the training parameters for frontal face detector
NSString *faceCascadePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalcatface"
                                                            ofType:@"xml"];

NSString *uperBodyCascadePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_upperbody"
                                                            ofType:@"xml"];

const CFIndex CASCADE_NAME_LEN = 2048;
char *CASCADE_NAME = (char *) malloc(CASCADE_NAME_LEN);
CascadeClassifier faceDetector;
CascadeClassifier bodyDetector;
vector<cv::Mat> _faceImgs;

- (instancetype)init
{
    self = [super init];
    if (self) {
        CFStringGetFileSystemRepresentation( (CFStringRef)faceCascadePath, CASCADE_NAME, CASCADE_NAME_LEN);
        faceDetector.load(CASCADE_NAME);
        ///
        CFStringGetFileSystemRepresentation( (CFStringRef)uperBodyCascadePath, CASCADE_NAME, CASCADE_NAME_LEN);
        bodyDetector.load(CASCADE_NAME);

    }
    return self;
}

- (void)processFrame:(cv::Mat &)frame {
    // example: make it gray
//    cv::cvtColor(frame, frame, cv::COLOR_BGRA2GRAY);
    
    [self faceDetection:frame];
    
    //Debugando posição de desenho
//    int radius = 100;
//    cv::Point center( 0 + radius/2 , 0  + radius/2);
//    cv::Point frameSize (frame.cols/2, frame.rows/2);
//    circle( frame, center, radius, Scalar( 255, 0, 0 ), 4, 8, 0 );
}

//- (void)faceDetection:(cv::Mat &)frame {
//    
//    std::vector<cv::Rect> faceRects;
//    ////////
//    double scalingFactor = 1.1;
//    int minNeighbors = 2;
//    int flags = 0|CASCADE_SCALE_IMAGE;
//    cv::Size minimumSize(30,30);
//    cv::Size maximumSize(300,300);
//
//    //ADICONANDO O HEAD DETECTOR
//    
//    Mat frame_gray;
//    cvtColor( frame, frame_gray, COLOR_BGR2GRAY );
//    equalizeHist( frame_gray, frame_gray );
//
//    
//    //IGUAl ao do arquivo cpp
//    //faceDetector.detectMultiScale( frame_gray, faceRects, 1.1, 2, 0|CASCADE_SCALE_IMAGE, cv::Size(30, 30) );
//    
//    faceDetector.detectMultiScale(frame, faceRects,
//                                  scalingFactor, minNeighbors, flags,
//                                  minimumSize );
//
//    
//    if(faceRects.size() != 0) {
////        NSLog(@"faceRects[1].x = %i", faceRects[1].x);
////        NSLog(@"faceRects[1].y = %i", faceRects[1].y);
//
//    }
//        for ( size_t i = 0; i < faceRects.size(); i++ )
//    {
//        cv::Point center( faceRects[i].x + faceRects[i].width, faceRects[i].y + faceRects[i].height );
//        ellipse( frame, center, cv::Size( faceRects[i].width/2, faceRects[i].height/2 ), 0, 0, 360, Scalar( 255, 0, 255 ), 4, 8, 0 );
//    }
//    
//    //ADICONANDO O BODY DETECTOR
//    
////    vector<cv::Rect> bodyRects;
////
////    
////    equalizeHist( frame_gray, frame_gray );
////    
////    
////    //mudei de img para frame
////    bodyDetector.detectMultiScale(frame_gray, faceRects,
////                                  scalingFactor, minNeighbors, flags,
////                                  minimumSize);
////    
////    for ( size_t i = 0; i < faceRects.size(); i++ )
////    {
////        cv::Point center( faceRects[i].x + faceRects[i].width, faceRects[i].y + faceRects[i].height );
////        ellipse( frame, center, cv::Size( faceRects[i].width/2, faceRects[i].height/2 ), 0, 0, 360, Scalar( 255, 0, 255 ), 4, 8, 0 );
////    }
//    
//}

- (void)faceDetection:(cv::Mat &)frame {
//    [self openCvFaceDetect: frame];
    [self detectAndDrawFacesOn:frame scale:2.0];
}


// MARK: - Detect face with OpenCV


// Not working properly
- (void)detectAndDrawFacesOn:(Mat&) img scale:(double) scale
{
    int i = 0;
    double t = 0;
    
    std::vector<cv::Rect> faceRects;
    
    const static Scalar colors[] =  { CV_RGB(0,0,255),
        CV_RGB(0,128,255),
        CV_RGB(0,255,255),
        CV_RGB(0,255,0),
        CV_RGB(255,128,0),
        CV_RGB(255,255,0),
        CV_RGB(255,0,0),
        CV_RGB(255,0,255)} ;
    Mat gray, smallImg( cvRound (img.rows/scale), cvRound(img.cols/scale), CV_8UC1 );
    
    cvtColor( img, gray, COLOR_BGR2GRAY );
    resize( gray, smallImg, smallImg.size(), 0, 0, INTER_LINEAR );
    equalizeHist( smallImg, smallImg );
    
    
    
    t = (double)cvGetTickCount();
    double scalingFactor = 1.1;
    int minRects = 2;
    cv::Size minSize(30,30);
    
    faceDetector.detectMultiScale( smallImg, faceRects,
                                         scalingFactor, minRects, 0,
                                         minSize );
    
    t = (double)cvGetTickCount() - t;

    vector<cv::Mat> faceImages;
    
    for( vector<cv::Rect>::const_iterator r = faceRects.begin(); r != faceRects.end(); r++, i++ )
    {
        cv::Mat smallImgROI;
        cv::Point center;
        Scalar color = colors[i%8];
        vector<cv::Rect> nestedObjects;
        rectangle(img,
                  cvPoint(cvRound(r->x*scale), cvRound(r->y*scale)),
                  cvPoint(cvRound((r->x + r->width-1)*scale), cvRound((r->y + r->height-1)*scale)),
                  color, 1, 8, 0);
        
        smallImgROI = smallImg(*r);
        
        faceImages.push_back(smallImgROI.clone());
    }
    
    @synchronized(self) {
        _faceImgs = faceImages;
    }
    
}













//
//
//// Other OpenCV face detection
//- ( void )openCvFaceDetect:(cv::Mat &)frame
//{
//    NSInteger                 i;
//    NSUInteger                scale;
//    Mat                * image;
//    IplImage                * smallImage;
//    CvHaarClassifierCascade * cascade;
//    CvMemStorage            * storage;
//    CvSeq                   * faces;
//    UIAlertView             * alert;
//    CGColorSpaceRef           colorSpaceRef;
//    CGContextRef              context;
//    CvRect                    rect;
//    CGRect                    faceRect;
//    
//    scale = 2;
//    
//    cvSetErrMode( CV_ErrModeParent );
//    
//    image      = &frame;
//    smallImage = cvCreateImage( cvSize( image->cols / scale, image->rows / scale ), IPL_DEPTH_8U, 3 );
//    
//    cvPyrDown( image, smallImage, CV_GAUSSIAN_5x5 );
//    
//    cascade = ( CvHaarClassifierCascade * )cvLoad( [ faceCascadePath cStringUsingEncoding: NSASCIIStringEncoding ], NULL, NULL, NULL );
//    storage = cvCreateMemStorage( 0 );
//    faces   = cvHaarDetectObjects( smallImage, cascade, storage, ( float )1.2, 2, CV_HAAR_DO_CANNY_PRUNING, cvSize( 20, 20 ) );
//    
//    cvReleaseImage( &smallImage );
//    
//    colorSpaceRef = CGColorSpaceCreateDeviceRGB();
//    context       = CGBitmapContextCreate(NULL, image->cols,
//                                          image->rows, 8,
//                                          image->cols * 4,
//                                          colorSpaceRef,
//                                          kCGImageAlphaPremultipliedLast |
//                                          kCGBitmapByteOrderDefault);
//    
////    CGContextDrawImage(context, CGRectMake( 0, 0, image->cols, image->rows ), image);
//    
//    CGContextSetLineWidth( context, 1 );
//    CGContextSetRGBStrokeColor( context, ( CGFloat )0, ( CGFloat )0, ( CGFloat )0, ( CGFloat )0.5 );
//    CGContextSetRGBFillColor( context, ( CGFloat )1, ( CGFloat )1, ( CGFloat )1, ( CGFloat )0.5 );
//    
//    if( faces->total == 0 )
//    {
//        alert = [ [ UIAlertView alloc ] initWithTitle: @"No faces" message: @"No faces were detected in the picture. Please try with another one." delegate: NULL cancelButtonTitle: @"OK" otherButtonTitles: nil ];
//        
//        [ alert show ];
//    }
//    else
//    {
//        for( i = 0; i < faces->total; i++ )
//        {
//            rect     = *( CvRect * )cvGetSeqElem( faces, i );
//            faceRect = CGContextConvertRectToDeviceSpace( context, CGRectMake( rect.x * scale, rect.y * scale, rect.width * scale, rect.height * scale ) );
//            
//            CGContextFillRect( context, faceRect );
//            CGContextStrokeRect( context, faceRect );
//        }
//    }
//    
//    CGContextRelease( context );
//    CGColorSpaceRelease( colorSpaceRef );
//    cvReleaseMemStorage( &storage );
//    cvReleaseHaarClassifierCascade( &cascade );
//    cvReleaseImage( &smallImage );
//}


@end
