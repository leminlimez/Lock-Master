#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@implementation LockMasterImageView
@end

@implementation LockMasterWindow
- (BOOL)_ignoresHitTest
{
	return YES;
}
+ (BOOL)_isSecure
{
	return YES;
}
@end

@implementation LockMaster
@synthesize springboardWindow, backView, imageView;
__strong static id _sharedObject;

+ (id)sharedInstance
{
	if (!_sharedObject) {
		_sharedObject = [[self alloc] init];
	}
	return _sharedObject;
}
+ (BOOL)sharedInstanceExist
{
	if (_sharedObject) {
		return YES;
	}
	return NO;
}
- (void) firstLoad
{
    return;
}
-(id)init
{
	self = [super init];
	if(self != nil) {
		@try {
			
			springboardWindow = [[LockMasterWindow alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
			springboardWindow.windowLevel = 99999999999;
			[springboardWindow setHidden:YES];
			springboardWindow.alpha = 1;
			[springboardWindow _setSecure:YES];
			[springboardWindow setUserInteractionEnabled:NO];
			springboardWindow.layer.cornerRadius = 1.0f;
			springboardWindow.layer.masksToBounds = YES;
			springboardWindow.layer.shouldRasterize  = NO;
			springboardWindow.backgroundColor = [UIColor blackColor];
			
			backView = [UIView new];
			backView.frame = springboardWindow.bounds;
			backView.backgroundColor = [UIColor blackColor];
			backView.alpha = 1.0f; // 0.5f
			backView.layer.masksToBounds = YES;
			[(UIView *)springboardWindow addSubview:backView];
			
			imageView = [LockMasterImageView new];
			imageView.frame = springboardWindow.bounds;
			imageView.contentMode = UIViewContentModeScaleAspectFill;
			
			[backView addSubview:imageView];
			
		} @catch (NSException * e) {
			
		}
	}
	return self;
}
- (void)restoreFrames
{
	imageView.alpha = 1.0f;
	backView.alpha = 1.0f;
	backView.frame = springboardWindow.bounds;
	imageView.frame = backView.bounds;
	imageView.transform = CGAffineTransformIdentity;
	backView.transform = CGAffineTransformIdentity;
	imageView.image = nil;
	springboardWindow.hidden = YES;
}
- (void)animWithDuration:(double)duration source:(int)source animType:(int)animType
{
	[self restoreFrames];
	
	/*CGRect newFrameImage = imageView.frame;
	CGRect newFrameBack = backView.frame;
	
	CGAffineTransform newTransformImage = imageView.transform;
	CGAffineTransform newTransformBack = backView.transform;
	
	if(source == 0) {
		if(animType == 0) {
			newFrameImage = CGRectMake(imageView.center.x,imageView.center.y,0,0);
		} else if(animType == 1) {
			newFrameImage = CGRectMake(imageView.frame.origin.x,-imageView.frame.size.height,imageView.frame.size.width,imageView.frame.size.height);
		} else if(animType == 2) {
			newFrameImage = CGRectMake(imageView.frame.origin.x,imageView.frame.size.height,imageView.frame.size.width,imageView.frame.size.height);
		} else if(animType == 3) {
			newFrameImage = CGRectMake(-imageView.frame.size.width,imageView.frame.origin.y,imageView.frame.size.width,imageView.frame.size.height);
		} else if(animType == 4) {
			newFrameImage = CGRectMake(imageView.frame.size.width,imageView.frame.origin.y,imageView.frame.size.width,imageView.frame.size.height);
		} else if(animType == 5) {
			newFrameImage = CGRectMake(imageView.frame.origin.x,-imageView.center.y,imageView.frame.size.width,imageView.frame.size.height);
			newFrameBack = CGRectMake(0,imageView.center.y,imageView.frame.size.width,0);
		} else if(animType == 6) {
			newFrameImage = CGRectMake(imageView.center.x,imageView.center.y,0,0);
			newTransformBack = CGAffineTransformMakeRotation(200 * M_PI/180);
		}
	}
	
	imageView.image = _UICreateScreenUIImage();
	springboardWindow.hidden = NO;
	
	float speed = arg1/2;
	
	if(animType == 7) {
		[imageView lp_explodeWithCallback:^{
			springboardWindow.hidden = YES;
			[self restoreFrames];
		}];
	} else if(animType == 8 || animType == 9) {
		UIVisualEffectView* effectView;
		if(objc_getClass("UIVisualEffectView") != nil) {
			effectView = [[objc_getClass("UIVisualEffectView") alloc]init];
		} else {
			effectView = (UIVisualEffectView *)[UIView new];
		}
		effectView.alpha = 1.0f;
		effectView.frame = imageView.bounds;
		[imageView addSubview:effectView];
		
		[UIView animateWithDuration:speed animations:^{
			//effectView.alpha = 1.0f;
			if(objc_getClass("UIBlurEffect") != nil) {
				effectView.effect = [objc_getClass("UIBlurEffect") effectWithStyle:(UIBlurEffectStyle)((animType==9)?3:0)];
			}
		} completion:^(BOOL finished) {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, speed * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
				springboardWindow.hidden = YES;
				[self restoreFrames];
				[effectView removeFromSuperview];
			});
		}];
	} else {
		[UIView animateWithDuration:speed animations:^{
			imageView.frame = newFrameImage;
			backView.frame = newFrameBack;
			imageView.transform = newTransformImage;
			backView.transform = newTransformBack;
		} completion:^(BOOL finished) {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, speed * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
				springboardWindow.hidden = YES;
				[self restoreFrames];
			});
		}];
	}*/
}
@end