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
NSString *faceCascadePath = [[NSBundle mainBundle] pathForResource:@"frontalface_alt2"
                                                            ofType:@"xml"];

const CFIndex CASCADE_NAME_LEN = 2048;
char *CASCADE_NAME = (char *) malloc(CASCADE_NAME_LEN);
CascadeClassifier faceDetector;

- (instancetype)init
{
    self = [super init];
    if (self) {
        CFStringGetFileSystemRepresentation( (CFStringRef)faceCascadePath, CASCADE_NAME, CASCADE_NAME_LEN);
        faceDetector.load(CASCADE_NAME);


    }
    return self;
}

- (void)processFrame:(cv::Mat &)frame {
    // example: make it gray
    //cv::cvtColor(frame, frame, cv::COLOR_BGRA2GRAY);
    [self faceDetection:frame];
}

- (void)faceDetection:(cv::Mat &)frame {
    
    //cv::Mat img;
    vector<cv::Rect> faceRects;
    double scalingFactor = 1.1;
    int minNeighbors = 2;
    int flags = 0;
    cv::Size minimumSize(30,30);
    cv::Size maximumSize(300,300);

    //mudei de img para frame
    faceDetector.detectMultiScale(frame, faceRects,
                                  scalingFactor, minNeighbors, flags,
                                  minimumSize );
    
    ///
    Mat frame_gray;
    cvtColor( frame, frame_gray, COLOR_BGR2GRAY );
    equalizeHist( frame_gray, frame_gray );
    for ( size_t i = 0; i < faceRects.size(); i++ )
    {
        cv::Point center( faceRects[i].x + faceRects[i].width/2, faceRects[i].y + faceRects[i].height/2 );
        ellipse( frame, center, cv::Size( faceRects[i].width/2, faceRects[i].height/2 ), 0, 0, 360, Scalar( 255, 0, 255 ), 4, 8, 0 );
    }
}



@end
