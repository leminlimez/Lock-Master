#import <Foundation/Foundation.h>
#import "LockMasterPrefsRootListController.h"

@implementation LockMasterPrefsRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)openGithub {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/leminlimez/Lock-Master"] options:@{} completionHandler:nil];
}

- (void)openTwitter {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/LeminLimez"] options:@{} completionHandler:nil];
}

@end
