/*
This tweak is meant to be a more stable fork of the LockAnim tweak by julioverne.
Original tweak found here: https://github.com/julioverne/LockAnim
This tweak was also an adaptation of Disintegrate Lock.
Disintegrate Lock can be found here: https://github.com/p0358/DisintegrateLock/tree/master
*/

#import <UIKit/UIKit.h>
#import <Cephei/HBPreferences.h>
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>
#import <LockMaster-Swift.h>
#import <AudioToolbox/AudioServices.h>
#import <rootless.h>

#pragma mark - Global Constants
#define ANIMATION_TYPE_COUNT 13

#pragma mark - Preference Variables
BOOL enabled = YES;
BOOL disableInLPM = NO;
NSInteger animType = 0;
double animDuration = 0.25;
double fadeExtension = 0.2;
// Lock Sound
NSString *lockSound = @"Default";
NSString *lockSoundPath = @"";

#pragma mark - Global Variables
HBPreferences *prefs;
bool isAnimationInProgress = false;
int animationCounter = 0;

#pragma mark - Bundle Getter
NSBundle *LockMasterBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"LockMasterPreferences" ofType:@"bundle"];
        if (tweakBundlePath)
            bundle = [NSBundle bundleWithPath:tweakBundlePath];
        else
            bundle = [NSBundle bundleWithPath:ROOT_PATH_NS(@"/Library/PreferenceBundles/LockMasterPreferences.bundle")];
    });
    return bundle;
}

#pragma mark - Preference Methods
void setPrefs() {
	/*NSDictionary *preferences = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.leemin.lockmasterprefs"];
	enabled = [[preferences valueForKey:@"isEnabled"] boolValue];
	disableInLPM = [[preferences valueForKey:@"disableInLPM"] boolValue];
	animType = [[preferences valueForKey:@"animType"] integerValue];
	animDuration = [[preferences valueForKey:@"animDuration"] doubleValue];

	lockSound = [[preferences valueForKey:@"lockSound"] integerValue];*/

	HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:@"com.leemin.lockmasterprefs"];

	// register the preference variables
	[prefs registerBool:&enabled default:YES forKey:@"isEnabled"];
	[prefs registerBool:&disableInLPM default:NO forKey:@"disableInLPM"];

	[prefs registerInteger:&animType default:0 forKey:@"animType"];
	[prefs registerDouble:&animDuration default:0.25 forKey:@"animDuration"];
	[prefs registerDouble:&fadeExtension default:0.2 forKey:@"fadeExtension"];

	[prefs registerObject:&lockSound default:@"Default" forKey:@"customLockSound"];
	if (![lockSound isEqualToString:@"Default"] && ![lockSound isEqualToString:@""]) {
		lockSoundPath = [NSString stringWithFormat:@"%@/LockSounds/%@", [LockMasterBundle() bundlePath], lockSound];
	}
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
	-(void)playLockAnimation:(float)arg1 extendFadeBy:(double)arg2;
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

- (void)playLockAnimation:(float)totalTime extendFadeBy:(double)extendFade {
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
		if (localAnimType < 0 || localAnimType > ANIMATION_TYPE_COUNT)
			localAnimType = 0;
		
		[subView animateLock:localAnimType duration:totalTime extendFadeBy: extendFade completion:^{
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

#pragma mark - Lock Animation Hooks
%hook SBBacklightController
-(void)_animateBacklightToFactor:(float)arg1 duration:(double)arg2 source:(long long)arg3 silently:(BOOL)arg4 completion:(id)arg5 
{
	// source
	// 3 = manual lock
	// 8 = after timeout
	// f = SpringBoard launch
	if(
		enabled
		&& arg2 > 0
		&& (!disableInLPM || (![[NSProcessInfo processInfo] isLowPowerModeEnabled]))
		&& (arg1 == 0 && [self screenIsOn])
		&& !isAnimationInProgress
	) {
		arg2 = animDuration + fadeExtension;
		[lockMaster playLockAnimation:(arg2 - fadeExtension) extendFadeBy:fadeExtension];
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

#pragma mark - Sound Hooks

%hook SBSleepWakeHardwareButtonInteraction
- (void)_playLockSound {
	if (![lockSound isEqualToString:@"Default"] && [[NSFileManager defaultManager] fileExistsAtPath:lockSoundPath]) {
		NSURL *soundURL = [NSURL fileURLWithPath:lockSoundPath];
		SystemSoundID sound = 0;
		AudioServicesCreateSystemSoundID((CFURLRef) CFBridgingRetain(soundURL), &sound);
		AudioServicesPlaySystemSound((SystemSoundID) sound);
		return;
	}
	%orig;
}
%end

#pragma mark - Updating Preferences
%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, CFSTR("com.leemin.lockmaster.prefschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	setPrefs();
	%init;
}