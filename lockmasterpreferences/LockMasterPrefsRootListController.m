#import <Foundation/Foundation.h>
#import "LockMasterPrefsRootListController.h"
#import <rootless.h>

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

@implementation LockMasterPrefsRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
		for (PSSpecifier *specifier in _specifiers) {
			if ([[specifier propertyForKey:@"id"] isEqualToString:@"customLockSound"]) {
				NSMutableArray *validTitles = [[NSMutableArray alloc] init];
				NSMutableArray *validValues = [[NSMutableArray alloc] init];

				[validTitles addObject:@"Default"];
				[validValues addObject:@"Default"];

				NSString *audioPath = [NSString stringWithFormat:@"%@/LockSounds", [LockMasterBundle() bundlePath]];
				NSArray *audioFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:audioPath error:NULL];

				[audioFiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    				NSString *fileName = (NSString *)obj;
					if ([fileName hasSuffix:@".m4a"] || [fileName hasSuffix:@".mp3"] || [fileName hasSuffix:@".wav"]) {
						NSString *parsedTitle = [[fileName substringToIndex:[fileName length] - 4] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
						[validTitles addObject:parsedTitle];
						[validValues addObject:fileName];
					}
				}];
				[specifier setProperty:[validTitles copy] forKey:@"validTitles"];
				[specifier setProperty:[validValues copy] forKey:@"validValues"];
			}
		}
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
