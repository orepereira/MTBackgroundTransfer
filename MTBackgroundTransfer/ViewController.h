//
//  ViewController.h
//  MTBackgroundTransfer
//
//  Created by Jorge Costa on 10/16/13.
//  Copyright (c) 2013 MobileTuts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate,UIDocumentInteractionControllerDelegate, UIAlertViewDelegate>
// NEWCODE - UIAlertViewDelegate protocol


@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (retain, nonatomic) UIDocumentInteractionController *documentInteractionController;

@end
