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
	}

	return _specifiers;
}

// TODO: Save sound files to /var/jb/Library/LockMaster instead
- (NSArray *)lockSoundFileNames {
	if (!_lockSoundFileNames) {
		NSMutableArray *fileNames = [[NSMutableArray alloc] init];
		[fileNames addObject:@"Default"];
		
		NSString *audioPath = [NSString stringWithFormat:@"%@/LockSounds", [LockMasterBundle() bundlePath]];
		NSArray *audioFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:audioPath error:NULL];

		[audioFiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			NSString *fileName = (NSString *)obj;
			if ([fileName hasSuffix:@".m4a"] || [fileName hasSuffix:@".mp3"] || [fileName hasSuffix:@".wav"]) {
				[fileNames addObject:fileName];
			}
		}];
		_lockSoundFileNames = fileNames;
	}
	return _lockSoundFileNames;
}

- (NSArray *)LockSoundTitles {
	NSMutableArray *mutableTitles = [[self lockSoundFileNames] mutableCopy];
	for (int i = 0; i < [mutableTitles count]; i++) {
		NSString *fileName = [mutableTitles objectAtIndex:i];
		if (![fileName isEqualToString:@"Default"]) {
			NSString *parsedTitle = [[fileName substringToIndex:[fileName length] - 4] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
			[mutableTitles replaceObjectAtIndex:i withObject:parsedTitle];
		}
	}
	return mutableTitles;
}

- (NSArray *)LockSoundValues {
	return [self lockSoundFileNames];
}

- (void)openURLWithString:(NSString *)url {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
}

- (void)openSoundsFolder {
	[self openURLWithString:[NSString stringWithFormat:@"filza://view%@/LockSounds/", [LockMasterBundle() bundlePath]]];
}

- (void)openGithub {
	[self openURLWithString:@"https://github.com/leminlimez/Lock-Master"];
}

- (void)openTwitter {
	[self openURLWithString:@"https://twitter.com/LeminLimez"];
}

@end
