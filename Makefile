TARGET := iphone:clang:15.0:14.0
INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LockMaster

LockMaster_FILES = Tweak.x UIView+AnimateLock.swift AnimationType.swift CALayer+AnimateLock.swift
LockMaster_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += lockmasterpreferences
include $(THEOS_MAKE_PATH)/aggregate.mk
