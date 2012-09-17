//
//  LogViewer.h
//  iOS
//
//  Created by Morita Naoki on 2012/09/09.
//  Copyright (c) 2012年 molabo. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * LogViwer
 */

@interface LogViewer : UIView

/// @name Class Method

/** Get the singleton instance of LogViewer
 *
 * @return The singleton instance of LogViewer
 */
+ (LogViewer *)sharedManager;

/// @name Output Log in LogViewer

/** Output Log with the title
 *
 * The title must be NSString.
 * @param log Something you want to log. It must be an object.
 * @param title Something you want to name the log. It must be NSString.
 * @return void
 */
- (void)log:(id)log withTitle:(NSString *)title;

/** Output Log with the title
 *
 * The title must be NSString.
 * @param log Something you want to log. It must be an object.
 * @param title Something you want to name the log. It must be NSString.
 * @return void
 */
- (void)log:(id)log;

/// @name Setting

/// Show a log view or not. Default value is Yes.
@property (nonatomic, assign) BOOL enabled;

/// Show date or not. Default value is YES.
@property (nonatomic, assign) BOOL showDate;

/// Show time or not. Default value is YES.
@property (nonatomic, assign) BOOL showTime;

/// You can change a base color. Default value is [UIColor blackColor].
@property (nonatomic, strong) UIColor *baseColor;

/// You can customize textView
@property (nonatomic, strong) UITextView *logTextView;

/// You can customize backgroundView
@property (nonatomic, strong) UIImageView *backgroundView;

@end
