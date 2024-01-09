TARGET := iphone:clang:15.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = LockMasterPreferences

LockMasterPreferences_FILES = LockMasterPrefsRootListController.m
LockMasterPreferences_FRAMEWORKS = UIKit
LockMasterPreferences_PRIVATE_FRAMEWORKS = Preferences
LockMasterPreferences_INSTALL_PATH = /Library/PreferenceBundles
LockMasterPreferences_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
