#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListItemsController.h>
#import <Cephei/HBPreferences.h>

@interface LockMasterPrefsRootListController : PSListController {
    NSArray *_lockSoundFileNames;
}

- (NSArray *)specifiers;

@end
