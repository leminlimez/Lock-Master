/*
This tweak is meant to be a more stable fork of the LockAnim tweak by julioverne.
Original tweak found here: https://github.com/julioverne/LockAnim
This tweak was also an adaptation of Disintegration Lock.
Disintegration Lock can be found here: https://github.com/p0358/DisintegrateLock/tree/master
*/

#import <rootless.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>
#import <LockMaster-Swift.h>

#pragma mark - Preference Variables
BOOL enabled = YES;
int animType = 0;
double animDuration = 0.5;

#pragma mark - Global Variables
bool isAnimationInProgress = false;
int animationCounter = 0;

#pragma mark - Preference Methods
void setPrefs() {
	NSDictionary *preferences = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.leemin.lockmasterprefs"];
	enabled = [[preferences valueForKey:@"isEnabled"] boolValue];
	animType = [[preferences valueForKey:@"animType"] integerValue];
	animDuration = [[preferences valueForKey:@"animDuration"] doubleValue];
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	setPrefs();
}

#pragma mark - Necessary Classes
extern UIImage* _UICreateScreenUIImage();

@interface SBBacklightController : NSObject
	@property (nonatomic,readonly) BOOL screenIsOn; 
	@property (nonatomic,readonly) BOOL screenIsDim;
@end



@interface UIWindow ()
- (void)_setSecure:(BOOL)arg1;
@end

#pragma mark - Main Class
@interface LockMaster:NSObject {
	UIWindow *springboardWindow;
	UIView *mainView;
	UIView *subView;
	UIImageView *imageView;
	UIView *whiteOverlay;
}
	-(id)init;
	-(void)playLockAnimation:(float)arg1;
	-(void)reset;
@end

static LockMaster *__strong lockMaster;

@implementation LockMaster
-(id)init
{
	self = [super init];

	if (self != nil) {
		@try {
			isAnimationInProgress = false;
			animationCounter = 0;

			springboardWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
			//springboardWindow.windowLevel = UIWindowLevelAlert + 2;
			springboardWindow.windowLevel = 10000; // to display above some tweaks that have too big window levels like 9999 (requested for MilkyWay2 in this case)
			[springboardWindow setHidden:YES];
			[springboardWindow _setSecure:YES];
			[springboardWindow setUserInteractionEnabled:NO];
			[springboardWindow setAlpha:1.0];
			springboardWindow.backgroundColor = [UIColor blackColor];
			//[springboardWindow makeKeyAndVisible];

			subView = [[UIView alloc] initWithFrame:springboardWindow.bounds];
			[subView setAlpha:1.0f];
			subView.backgroundColor = [UIColor blackColor];
			subView.layer.masksToBounds = YES;
			[springboardWindow addSubview:subView];

			imageView = [[UIImageView alloc] initWithFrame:springboardWindow.bounds];
			imageView.frame = springboardWindow.bounds;
			imageView.contentMode = UIViewContentModeScaleAspectFill;
			[subView addSubview:imageView];
		} @catch (NSException *e) {
			
		}
	}
	return self;
}

- (void)playLockAnimation:(float)totalTime {
	@try {
		isAnimationInProgress = true;
		animationCounter++;
		int localAnimationCounter = animationCounter;

		// needed to give the UIImage's ownership to ARC
		CFTypeRef ref = (__bridge CFTypeRef)_UICreateScreenUIImage();
		UIImage *img = (__bridge_transfer UIImage*)ref;
		imageView.image = img;

		// show animation window
		[springboardWindow setHidden:NO];

		NSInteger localAnimType = animType;
		if (localAnimType < 0 || localAnimType > 7)
			localAnimType = 0;
		
		[subView animateLock:localAnimType duration:totalTime completion:^{
			if (isAnimationInProgress && localAnimationCounter == animationCounter) {
				// the purpose of animationCounter is to prevent this block from a stray cancelled animation reset a new ongoing animation
				[self reset];
				isAnimationInProgress = false;
			}
		}];
	} @catch (NSException *e) {
		isAnimationInProgress = false;
	}
}

-(void)reset {
	[springboardWindow setHidden:YES];

	[imageView removeFromSuperview];
	[subView removeFromSuperview];

	subView = [[UIView alloc] initWithFrame:springboardWindow.bounds];
	[subView setAlpha:1.0f];
	subView.backgroundColor = [UIColor blackColor];
	subView.layer.masksToBounds = YES;
	[springboardWindow addSubview:subView];

	imageView = [[UIImageView alloc] initWithFrame:springboardWindow.bounds];
	imageView.frame = springboardWindow.bounds;
	imageView.contentMode = UIViewContentModeScaleAspectFill;
	[subView addSubview:imageView];

	subView.layer.cornerRadius = 0;

	imageView.frame = springboardWindow.bounds;
	imageView.transform = CGAffineTransformIdentity;
	imageView.image = nil;
}
@end

#pragma mark - Hooks
%hook SBBacklightController
-(void)_animateBacklightToFactor:(float)arg1 duration:(double)arg2 source:(long long)arg3 silently:(BOOL)arg4 completion:(id)arg5 
{
	// source
	// 3 = manual lock
	// 8 = after timeout
	// f = SpringBoard launch
	if(enabled && (arg1 == 0 && [self screenIsOn]) && !isAnimationInProgress) {
		arg2 = animDuration + 0.1;
		[lockMaster playLockAnimation:arg2 - 0.1];
	}
	%orig(arg1, arg2, arg3, arg4, arg5);
}

-(void)turnOnScreenFullyWithBacklightSource:(long long)arg1 {
	// manual power button press = 3
	// home button press = 2
	if (isAnimationInProgress) {
		[lockMaster reset];
		isAnimationInProgress = false;
	}
	%orig;
}
%end

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application
{
	%orig;
	lockMaster = [[LockMaster alloc] init];
}
%end

#pragma mark - Updating Preferences
%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, CFSTR("com.leemin.lockmaster.prefschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	%init;
}