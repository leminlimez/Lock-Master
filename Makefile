TARGET := iphone:clang:15.0
INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LockMaster

LockMaster_FILES = Tweak.x LockMaster.x
LockMaster_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += lockmasterpreferences
include $(THEOS_MAKE_PATH)/aggregate.mk
