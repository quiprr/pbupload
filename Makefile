export ARCHS = arm64 arm64e
export TARGET := iphone:clang:14.0:10.0
export PREFIX = $(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/

DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TOOL_NAME = pbupload

pbupload_FILES = Sources/pbupload.m
pbupload_CFLAGS = -fobjc-arc -DTHEOS_LEAN_AND_MEAN
pbupload_FRAMEWORKS = Foundation UIKit
pbupload_CODESIGN_FLAGS = -Sentitlements.plist
pbupload_INSTALL_PATH = /usr/local/bin

include $(THEOS_MAKE_PATH)/tool.mk

purge::
	$(ECHO_BEGIN)$(PRINT_FORMAT_RED) "Purging"$(ECHO_END); $(ECHO_PIPEFAIL)
	find . -name '.theos' -exec rm -rf {} \; -o -name 'packages' -exec rm -rf {} \; -o -name '.DS_Store' -exec rm -rf {} \; -o -name '.dragon' -exec rm -rf {} \; -o -name '*.ninja' -exec rm -rf {} \; 2>&1 | grep -v 'find' ; echo -n ""
