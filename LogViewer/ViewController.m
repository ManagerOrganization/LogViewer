//
//  ViewController.m
//  LogViewer
//
//  Created by MORITA NAOKI on 2012/09/10.
//  Copyright (c) 2012年 molabo. All rights reserved.
//

#import "ViewController.h"

#import "LogViewer.h"

@interface ViewController () {
    LogViewer *logViewer;
}

@end

@implementation ViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        logViewer = [LogViewer sharedManager];
        [logViewer log:@"initWithCoder"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [logViewer log:@"viewDidLoad"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [logViewer log:@"viewDidUnLoad"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)log:(id)sender
{
    [logViewer log:@"Log Button Tapped!"];
}

@end
