//
//  ViewController.m
//  MTBackgroundTransfer
//
//  Created by Jorge Costa on 10/16/13.
//  Copyright (c) 2013 MobileTuts. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"


static NSString *DownloadURLString = @"https://developer.apple.com/library/ios/documentation/General/Conceptual/CocoaTouch64BitGuide/CocoaTouch64BitGuide.pdf";

@implementation ViewController{
    // NEWCODE
    NSURL *destinationURL;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
	
    // Do any additional setup after loading the view, typically from a nib.
    self.session = [self backgroundSession];

    self.progressView.progress = 0;
    self.progressView.hidden = YES;
}

- (IBAction)start:(id)sender {
	if (self.downloadTask) {
        return;
    }

    NSURL *downloadURL = [NSURL URLWithString:DownloadURLString];
	NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
	self.downloadTask = [self.session downloadTaskWithRequest:request];
    [self.downloadTask resume];
    
    self.progressView.hidden = NO;
}

- (NSURLSession *)backgroundSession {
	static NSURLSession *session = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.example.apple-samplecode.SimpleBackgroundTransfer.BackgroundSession"];
		session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
	});
	return session;
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    if (downloadTask == self.downloadTask) {
        double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        NSLog(@"DownloadTask: %@ progress: %lf", downloadTask, progress);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = progress;
        });
    }
}

// NEWCODE - New method
- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
    return self;
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)downloadURL {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectory = [URLs objectAtIndex:0];
    
    NSURL *originalURL = [[downloadTask originalRequest] URL];
    // NEWCODE - ivar instead of property
    destinationURL = [documentsDirectory URLByAppendingPathComponent:[originalURL lastPathComponent]];
    
    NSError *errorCopy;
    
    // For the purposes of testing, remove any esisting file at the destination.
    [fileManager removeItemAtURL:destinationURL error:NULL];
    BOOL success = [fileManager copyItemAtURL:downloadURL toURL:destinationURL error:&errorCopy];
    if (success) {
        
        // NEWCODE
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.hidden = YES;
                
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Preview" message:@"The document is ready!!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        });

    } else {
        NSLog(@"Error during the copy: %@", [errorCopy localizedDescription]);
    }
}

// NEWCODE - New method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Ok"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //download finished - open the pdf
            _documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:destinationURL];
            
            // Configure Document Interaction Controller
            [_documentInteractionController setDelegate:self];
            
            [_documentInteractionController presentPreviewAnimated:YES];
            
        });
    }

}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {

    if (error == nil) {
        NSLog(@"Task: %@ completed successfully", task);
    } else {
        NSLog(@"Task: %@ completed with error: %@", task, [error localizedDescription]);
    }
	
    double progress = (double)task.countOfBytesReceived / (double)task.countOfBytesExpectedToReceive;
	dispatch_async(dispatch_get_main_queue(), ^{
		self.progressView.progress = progress;
	});
    
    self.downloadTask = nil;
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.backgroundSessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
        appDelegate.backgroundSessionCompletionHandler = nil;
        completionHandler();
    }
    
    NSLog(@"All tasks are finished");
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
