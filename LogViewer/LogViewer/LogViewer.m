//
//  LogViewer.m
//  iOS
//
//  Created by Morita Naoki on 2012/09/09.
//  Copyright (c) 2012年 molabo. All rights reserved.
//

#import "LogViewer.h"

#define kLogViewerTopSpaceHeight     20.0
#define kLogViewerBottomSpaceHeight  20.0

#define LogViewerName       @"LogViewer"
#define LogViewerVersion    @"0.7"

enum State {
    StateNone = 0,
    StatePositioning,
    StateSizing
    };

enum DisplayMode {
    DisplayModeLog =0,
    DisplayModeInfoPlist
};

@interface LogViewer () <UITextViewDelegate>
{    
    // External Variables
    BOOL enabled_;
    BOOL showDate_;
    BOOL showTime_;
    UIColor *baseColor_;
    
    // Inner Valiables;
    CGRect viewRect;
    enum State state;
    UILabel *topView;
    UIImageView *bottomView;
    UIButton *leftButton;
    UIButton *rightButton;
    UIButton *modeButton;
    
    CGPoint touchPoint;
    
    // infoPlist's info
    NSMutableArray *infoArray;
    NSString *infoText;
    NSString *textViewText;
    enum DisplayMode displayMode;
}
@end

@implementation LogViewer

static LogViewer* sharedManager = nil;
+ (LogViewer *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedManager = [[LogViewer alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    });
    return sharedManager;
}

- (id)initWithFrame:(CGRect)frame_
{
    self = [super initWithFrame:frame_];
    if (self) {
        
        viewRect = CGRectMake(0.0, 0.0, frame_.size.width, frame_.size.height);
        
        self.frame = frame_;
        
        // Initialize values
        state       = StateNone;
        displayMode = DisplayModeLog;
        enabled_    = YES;
        showDate_   = YES;
        showTime_   = YES;
        baseColor_  = [UIColor blackColor];
        
        // Allocations
        float leftButtonWidth   = 20.0;
        float rightButtonWidth  = 20.0;
        float adjust        = 2.0;
        CGRect bgRect           = CGRectMake(viewRect.origin.x, viewRect.origin.y,viewRect.size.width,viewRect.size.height);
        CGRect topViewRect      = CGRectMake(viewRect.origin.x+adjust,
                                             viewRect.origin.y+adjust,
                                             viewRect.size.width-adjust*2,
                                             kLogViewerTopSpaceHeight-adjust*2);
        CGRect textRect         = CGRectMake(viewRect.origin.x,
                                             kLogViewerTopSpaceHeight,
                                             viewRect.size.width,
                                             viewRect.size.height-kLogViewerTopSpaceHeight-kLogViewerBottomSpaceHeight);
        CGRect bottomViewRect   = CGRectMake(viewRect.origin.x+adjust,
                                             viewRect.size.height-kLogViewerBottomSpaceHeight+adjust,
                                             viewRect.size.width-adjust*2,
                                             kLogViewerBottomSpaceHeight-adjust*2);
        CGRect leftButtonRect   = CGRectMake(viewRect.origin.x+adjust,
                                             viewRect.size.height-kLogViewerBottomSpaceHeight+adjust,
                                             leftButtonWidth-adjust*2,
                                             kLogViewerBottomSpaceHeight-adjust*2);
        CGRect rightButtonRect  = CGRectMake(viewRect.size.width-rightButtonWidth+adjust,
                                             viewRect.size.height-kLogViewerBottomSpaceHeight+adjust,
                                             rightButtonWidth-adjust*2,
                                             kLogViewerBottomSpaceHeight-adjust*2);
        CGRect modeButtonRect   = CGRectMake(viewRect.origin.x+leftButtonRect.size.width+adjust*2,
                                             viewRect.size.height-kLogViewerBottomSpaceHeight+adjust,
                                             viewRect.size.width-(leftButtonRect.size.width+rightButtonRect.size.width+adjust*2*2),
                                             kLogViewerBottomSpaceHeight-adjust*2);
        
        // Background View
        self.backgroundView = [[UIImageView alloc] initWithFrame:bgRect];
        self.backgroundView.backgroundColor = self.baseColor;
        self.backgroundView.alpha = 0.7;
        self.backgroundView.autoresizingMask =
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleHeight |
        UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.backgroundView];
        
        // Top View
        topView = [[UILabel alloc] initWithFrame:topViewRect];
        topView.backgroundColor = self.baseColor;
        topView.textColor = [UIColor whiteColor];
        topView.textAlignment = UITextAlignmentCenter;
        topView.font = [UIFont systemFontOfSize:12.0];
        topView.text = [NSString stringWithFormat:@"%@ %@",LogViewerName,LogViewerVersion];
        topView.alpha = 1.0;
        topView.autoresizingMask =
        UIViewAutoresizingFlexibleWidth;
        topView.contentMode = UIViewContentModeCenter;
        [self addSubview:topView];
        
        // Text View
        self.logTextView = [[UITextView alloc] initWithFrame:textRect];
        self.logTextView.delegate = self;
        self.logTextView.editable = NO;
        self.logTextView.backgroundColor = [UIColor clearColor];
        self.logTextView.textColor = [UIColor whiteColor];
        self.logTextView.autoresizingMask =
        UIViewAutoresizingFlexibleHeight |
        UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.logTextView];
        
        // Bottom View
        bottomView = [[UIImageView alloc] initWithFrame:bottomViewRect];
        bottomView.alpha = 1.0;
        bottomView.autoresizingMask =
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleWidth;
        bottomView.contentMode = UIViewContentModeCenter;
        [self addSubview:bottomView];
        
        // Setting Button
        leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = leftButtonRect;
        leftButton.autoresizingMask =
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleRightMargin;
        [leftButton setImage:[UIImage imageNamed:@"gear"] forState:UIControlStateNormal];
        [self addSubview:leftButton];
        
        // Sizing Button
        rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton.frame = rightButtonRect;
        rightButton.autoresizingMask =
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleLeftMargin;
        rightButton.userInteractionEnabled = NO;
        [rightButton setImage:[UIImage imageNamed:@"size"] forState:UIControlStateNormal];
        [self addSubview:rightButton];
        
        // Mode Button
        modeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        modeButton.frame = modeButtonRect;
        modeButton.autoresizingMask =
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleWidth;
        modeButton.contentMode = UIViewContentModeCenter;
        modeButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        modeButton.backgroundColor = self.baseColor;
        [modeButton addTarget:self action:@selector(modeChange:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:modeButton];
        [self modeChange:modeButton];
        [self modeChange:modeButton];
        
        // infoPlist
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        infoArray = [NSMutableArray array];
        [self processParsedObject:infoDict];
        
        NSString *oldKey = nil;
        NSMutableArray *texts = [NSMutableArray array];
        for (int i=0; i<[infoArray count]; i++) {
            NSMutableArray *element = [infoArray objectAtIndex:i];
            NSString *key = [element objectAtIndex:0];
            NSString *string = [element objectAtIndex:1];
            
            if (![key isEqualToString:oldKey]) {
                NSString *line = @"---";
                [texts addObject:[NSString stringWithFormat:@"%@\n%@:\n%@",line,key,string]];
            } else {
                [texts addObject:[NSString stringWithFormat:@"%@",string]];
            }
            
            oldKey = [NSString stringWithString:key];
        }
        infoText = [texts componentsJoinedByString:@"\n"];
    }
    return self;
}


#pragma mark - InfoText

-(void)processParsedObject:(id)object{
    [self processParsedObject:object key:nil depth:0 parent:nil];
}

-(void)processParsedObject:(id)object key:(NSString *)key depth:(int)depth parent:(id)parent{
    
    if([object isKindOfClass:[NSDictionary class]]){
        
        for(NSString * key in [object allKeys]){
            id child = [object objectForKey:key];
            [self processParsedObject:child key:key depth:depth+1 parent:object];
        }
        
    }else if([object isKindOfClass:[NSArray class]]){
        
        for(id child in object){
            [self processParsedObject:child key:key depth:depth+1 parent:object];
        }
    }
    else{
//        NSLog(@"key:%@ value: %@  depth: %d",key, [object description],depth);
        if ([object isKindOfClass:[NSNumber class]]) {
            if ([object isEqualToNumber:[NSNumber numberWithBool:YES]]) {
                object = @"YES";
            } else if ([object isEqualToNumber:[NSNumber numberWithBool:NO]]) {
                object = @"NO";
            }
        }
        
        NSMutableArray *array = [NSMutableArray arrayWithObjects:key,[object description], nil];
        [infoArray addObject:array];
    }
}

#pragma mark - Properties
#pragma mark enabled
- (BOOL)enabled
{
    return enabled_;
}

- (void)setEnabled:(BOOL)enabled
{
    if (enabled_!=enabled) {
        enabled_=enabled;
        if (enabled_) {
            self.hidden = NO;
        } else {
            self.hidden = YES;
        }
    }
}

#pragma mark showDate
- (BOOL)showDate
{
    return showDate_;
}

- (void)setShowDate:(BOOL)showDate
{
    if (showDate_!=showDate) {
        showDate_=showDate;
    }
}

#pragma mark showTime
- (BOOL)showTime
{
    return showTime_;
}

- (void)setShowTime:(BOOL)showTime
{
    if (showTime_!=showTime) {
        showTime_=showTime;
    }
}

#pragma mark baseColor
- (UIColor *)baseColor
{
    return baseColor_;
}

- (void)setBaseColor:(UIColor *)baseColor
{
    if (baseColor_!=baseColor) {
        baseColor_=nil;
        baseColor_=baseColor;
        
        [self updateBaseColor];
    }
}

- (void)updateBaseColor
{
    self.backgroundView.backgroundColor = self.baseColor;
    topView.backgroundColor = self.baseColor;
    modeButton.backgroundColor = self.baseColor;
}

#pragma mark - Log

- (void)log:(id)log withTitle:(NSString *)title
{
    if (!self.enabled) return;
    
//    NSLog(@"contentOffset: %f",self.logTextView.contentOffset.y+self.logTextView.frame.size.height);
//    NSLog(@"contentSize  : %f",self.logTextView.contentSize.height);
    
    // Scroll or not
    BOOL scroll = NO;
    if (self.logTextView.contentSize.height-self.logTextView.contentOffset.y<self.logTextView.frame.size.height*2) {
        scroll = YES;
        NSOperationQueue *queue = [NSOperationQueue mainQueue];
        [queue cancelAllOperations];
        [queue addOperationWithBlock:^{
            [self scrollToLastSentence];
        }];
    }
    
    // Show title or not
    if ([title length]>0) {
        log = [NSString stringWithFormat:@"%@: %@",title,log];
    } else {
        log = [NSString stringWithFormat:@"%@",log];
    }
    
    // Output log on console
    NSLog(@"%@",log);
    
    // Make an additional information string
    NSString *additionalInfo = @"";
    
    // Make a date string
    if (self.showDate) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat: @"yyyy-MM-dd"];    // 2009-02-01
        NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
        if ([additionalInfo length]>0) {
            dateString = [@" " stringByAppendingString:dateString];
        }
        additionalInfo = [additionalInfo stringByAppendingString:dateString];
    }
    
    // Make a time string
    if (self.showTime) {
        NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
        [timeFormat setDateFormat: @"HH:mm:ss"]; // 19:50:41
        NSString *timeString = [timeFormat stringFromDate:[NSDate date]];
        if ([additionalInfo length]>0) {
            timeString = [@" " stringByAppendingString:timeString];
        }
        additionalInfo = [additionalInfo stringByAppendingString:timeString];
    }
    
    // Generate a full log string
    if ([additionalInfo length]>0) {
        additionalInfo = [NSString stringWithFormat:@"[%@] ",additionalInfo];
        log = [additionalInfo stringByAppendingString:log];
    }
    
    // Start a new line when there is a line
    if (self.logTextView.hasText) {
        log = [@"\n" stringByAppendingString:log];
    }
    
    // Insert log string to text view
    self.logTextView.text = [self.logTextView.text stringByAppendingString:log];
    
    [self.window bringSubviewToFront:self];
}

- (void)log:(id)log
{
    [self log:log withTitle:nil];
}

- (void)scrollToLastSentence
{
    // Scroll as for showing the last sentence
    int lng = [self.logTextView.text length];
    NSRange range;
    range.location = lng;
    range.length = 0;
    [self.logTextView scrollRangeToVisible:range];
}

#pragma mark - Mode

- (void)modeChange:(id)sender
{
    if (displayMode==DisplayModeLog) {
        displayMode = DisplayModeInfoPlist;
        
        // exchangeTexts
        textViewText = self.logTextView.text;
        self.logTextView.text = infoText;
        
        [modeButton setTitle:@"Mode: info.plist" forState:UIControlStateNormal];
    } else {
        displayMode = DisplayModeLog;
        
        // exchangeTexts
        self.logTextView.text = textViewText;
        
        [modeButton setTitle:@"Mode: log" forState:UIControlStateNormal];
    }
}

#pragma mark - Move

// Change the size of the view
- (void)changeSize:(CGSize)newSize
{
    float newWidth = newSize.width;
    float newHeight = newSize.height;
    
    // Don't reduce the size than the designated size
    float minWidth = 40.0;
    float minHeight = kLogViewerTopSpaceHeight+kLogViewerBottomSpaceHeight;
    if (newSize.width<minWidth) {
        newWidth = minWidth;
    }
    if (newSize.height<minHeight) {
        newHeight = minHeight;
    }
    // Do nothing when the size will be bigger the the screen size
    CGSize appSize = [UIScreen mainScreen].bounds.size;
    float maxWidth = appSize.width-self.frame.origin.x;
    float maxHeight = appSize.height-self.frame.origin.y;
    if (newSize.width>maxWidth) {
        newWidth = maxWidth;
    }
    if (newSize.height>maxHeight) {
        newHeight = maxHeight;
    }
    
    CGRect newRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, newWidth, newHeight);
    
    // Chane to the new size
    self.frame = newRect;
}

// Change the position
- (void)changePosition:(CGPoint)newOrigin
{
    // The screen size is the biggest size
    BOOL statusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    CGRect appRect;
    if (statusBarHidden) {
        appRect = [UIScreen mainScreen].bounds;
    } else {
        appRect = [UIScreen mainScreen].applicationFrame;
    }
    if (newOrigin.x<appRect.origin.x) {
        newOrigin.x=0.0;
    }
    if (newOrigin.y<appRect.origin.y) {
        newOrigin.y=appRect.origin.y;
    }
    if (newOrigin.x+self.frame.size.width>appRect.size.width+appRect.origin.x) {
        newOrigin.x = ceil(appRect.size.width-self.frame.size.width);
    }
    if (newOrigin.y+self.frame.size.height>appRect.size.height+appRect.origin.y) {
        newOrigin.y = ceil(appRect.origin.y+appRect.size.height-self.frame.size.height);
    }
    
    // Don't be bigger than the screen size
    float newOriginalHeight = self.frame.size.height;
    if (newOrigin.y+self.frame.size.height>appRect.size.height)
    {
        newOriginalHeight = appRect.size.height-newOrigin.y;
    }
    
    CGRect newSelfRect = CGRectMake(newOrigin.x,newOrigin.y,self.frame.size.width,self.frame.size.height);
    self.frame = newSelfRect;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint pos = [touch locationInView:self];
//    NSLog(@"Began x: %f, y:%f",pos.x, pos.y);
    
    // Branching process according to the touch point
    CGRect topRect = CGRectMake(viewRect.origin.x,viewRect.origin.y,self.frame.size.width,kLogViewerTopSpaceHeight);
    CGRect bottomRect = CGRectMake(0.0,self.frame.size.height-kLogViewerBottomSpaceHeight,self.frame.size.width,kLogViewerBottomSpaceHeight);
    if (CGRectContainsPoint(topRect, pos)) {
        state=StatePositioning;
    } else if (CGRectContainsPoint(bottomRect, pos)) {
        state=StateSizing;
    } else {
        state=StateNone;
    }
    
    touchPoint = CGPointMake(pos.x, pos.y);
}

- (void)adjustViews
{
    // Adjust TopView
//    NSLog(@"%f",self.frame.size.width);
    if (self.frame.size.width<80.0) {
        topView.text = @"Log";
    } else {
        topView.text = [NSString stringWithFormat:@"%@ %@",LogViewerName,LogViewerVersion];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint pos = [touch locationInView:self];
//    NSLog(@"Move x: %f, y:%f",pos.x, pos.y);
    
    float moveX = touchPoint.x - pos.x;
    float moveY = touchPoint.y - pos.y;
    
    if (state==StateSizing)
    {
        float newWidth = self.frame.size.width-moveX;
        float newHeight = self.frame.size.height-moveY;
        
        [self changeSize:CGSizeMake(newWidth, newHeight)];
        
        // touchPointの更新
        touchPoint = CGPointMake(pos.x, pos.y);
    }
    else if (state==StatePositioning)
    {
        float newOriginX = self.frame.origin.x-moveX;
        float newOriginY = self.frame.origin.y-moveY;
        
        [self changePosition:CGPointMake(newOriginX, newOriginY)];
    } else {
        
    }
    
    // Adjust Views
    [self adjustViews];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    UITouch *touch = [touches anyObject];
//    CGPoint pos = [touch locationInView:self];
//    NSLog(@"End x: %f, y:%f",pos.x, pos.y);
    
    state=StateNone;
}

@end
