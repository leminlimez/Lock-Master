#import <Foundation/Foundation.h>
#import "LockMasterPrefsRootListController.h"

@implementation LockMasterPrefsRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

@end
