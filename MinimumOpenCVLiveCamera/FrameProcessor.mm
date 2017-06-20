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

- (void)faceDetection:(cv::Mat &)frame {
    
    std::vector<cv::Rect> faceRects;
    ////////
    double scalingFactor = 1.1;
    int minNeighbors = 2;
    int flags = 0|CASCADE_SCALE_IMAGE;
    cv::Size minimumSize(30,30);
    cv::Size maximumSize(300,300);

    //ADICONANDO O HEAD DETECTOR
    
    Mat frame_gray;
    cvtColor( frame, frame_gray, COLOR_BGR2GRAY );
    equalizeHist( frame_gray, frame_gray );

    
    //IGUAl ao do arquivo cpp
    //faceDetector.detectMultiScale( frame_gray, faceRects, 1.1, 2, 0|CASCADE_SCALE_IMAGE, cv::Size(30, 30) );
    
    faceDetector.detectMultiScale(frame, faceRects,
                                  scalingFactor, minNeighbors, flags,
                                  minimumSize );

    
    if(faceRects.size() != 0) {
//        NSLog(@"faceRects[1].x = %i", faceRects[1].x);
//        NSLog(@"faceRects[1].y = %i", faceRects[1].y);

    }
        for ( size_t i = 0; i < faceRects.size(); i++ )
    {
        cv::Point center( faceRects[i].x + faceRects[i].width, faceRects[i].y + faceRects[i].height );
        ellipse( frame, center, cv::Size( faceRects[i].width/2, faceRects[i].height/2 ), 0, 0, 360, Scalar( 255, 0, 255 ), 4, 8, 0 );
    }
    
    //ADICONANDO O BODY DETECTOR
    
//    vector<cv::Rect> bodyRects;
//
//    
//    equalizeHist( frame_gray, frame_gray );
//    
//    
//    //mudei de img para frame
//    bodyDetector.detectMultiScale(frame_gray, faceRects,
//                                  scalingFactor, minNeighbors, flags,
//                                  minimumSize);
//    
//    for ( size_t i = 0; i < faceRects.size(); i++ )
//    {
//        cv::Point center( faceRects[i].x + faceRects[i].width, faceRects[i].y + faceRects[i].height );
//        ellipse( frame, center, cv::Size( faceRects[i].width/2, faceRects[i].height/2 ), 0, 0, 360, Scalar( 255, 0, 255 ), 4, 8, 0 );
//    }
    
}



@end
