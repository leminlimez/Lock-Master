extern "C" UIImage* _UICreateScreenUIImage();

@class LockMasterImageView;

@interface LockMaster: NSObject
{
    UIWindow *springboardWindow;
    UIView *backView;
    LockMasterImageView *imageView;
}
@property (nonatomic, strong) UIWindow* springboardWindow;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) LockAnimImageView *imageView;
+ (id)sharedInstance;
+ (BOOL)sharedInstanceExist;
- (void)firstload;
- (void)animWithDuration:(double)arg1 source:(int)source animType:(int)animType;
- (void)restoreFrames;
@end

@interface UIWindow ()
- (void)_setSecure:(BOOL)arg1;
@end

@interface LockMasterWindow : UIWindow
@end

@interface SBBacklightController : NSObject
@property (nonatomic,readonly) BOOL screenIsOn; 
@property (nonatomic,readonly) BOOL screenIsDim;
@end