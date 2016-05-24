GO_EASY_ON_ME = 1
DEBUG = 0
TARGET = iphone:9.0
ARCHS = armv7 arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FullNoPop
FullNoPop_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

