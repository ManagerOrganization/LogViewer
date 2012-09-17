# LogViewer

Naoki Morita

http://morizotter.com

[@morizotter](http://twitter.com/morizotter)

## Overview

**LogViewer** is a simple log viewer in iOS applications. You can see the debugging log on the app screen as if in Xcode log console. It's good for testing in the remote area without mac or a beginner who don't know the procedure the method calls yet. The view size is easily changeable. So this doesn't bother the screen touch event.

Adding this module is really easy. Just only 3 steps, you can use LogViewer. When you don't want to show the log on the screen, only you have to do is to disable the feature.



Download and try to do it!

## License

BSD-Style, with the full license available with the module in License.txt.

## Technical requirements

This module runs in ARC. Tested in iOS 5.0. 

It doesn't use xib files so both storyboard and the other will do.


## Adding the module to your iOS project

1. First, copy the LogViewer directory to any place in your Xcode project.
2. Second, copy the code below in AppDelegate.h and AppDelegate.m.

	AppDelegate.h
	* Just add the `#import` and instance variable.
	
	*#import*
	<pre>
	#import "LogViewer.h"</pre>
	
	*Instance variable*
	<pre>
	LogViewer *logViewer;</pre>

	AppDelegate.m
	* In `application:didFinishLaunchingWithOptions:`
	
	<pre>
	logViewer = [LogViewer sharedManager];
    logViewer.frame = [UIScreen mainScreen].applicationFrame;
    [self.window addSubview:logViewer];</pre>

3. Latly, write the code like below to output log in LogViewer.

	<pre>[logViewer log:@"applicationDidFinishLaunching"];</pre>


## How to use

Just write code 3. above where you want to show your log on screen. On the screen, you can change the size with the right-bottom button, the position with the title bar. The bottom line, there shows the current mode. Tapping there you can switch the mode to info.plist viewer. Tap agin you return to log viewer.

## Sample application

There is a sample application. It's really simple one with a full implementation. You can easily catch what the module do in this app.