#import <sys/utsname.h>

@interface UIKeyboardPreferencesController : NSObject
+ (UIKeyboardPreferencesController *)sharedPreferencesController;
- (BOOL)boolForKey:(int)key;
@end

BOOL override;

%hook UIKBRenderFactory

- (void)setAllowsPaddles:(BOOL)allowPaddles
{
	%orig([[objc_getClass("UIKeyboardPreferencesController") sharedPreferencesController] boolForKey:0x25]);
}

%end

%group Pref

static BOOL (*SystemHasCapabilities)(NSArray *);
MSHook(BOOL, SystemHasCapabilities, NSArray *keys)
{
	if (keys.count > 0) {
		if ([keys[0] isKindOfClass:[NSString class]]) {
			if ([keys[0] isEqualToString:@"telephony"] && override)
				return YES;
		}
	}
    return _SystemHasCapabilities(keys);
}

%hook KeyboardController

- (NSMutableArray *)loadSpecifiersFromPlistName:(NSString *)name target:(id)target bundle:(id)bundle
{
	override = YES;
	NSMutableArray *spec = %orig;
	override = NO;
	return spec;
}

%end

%end

%ctor
{
	%init;
	BOOL isPrefApp = [NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.Preferences"];
	if (isPrefApp) {
		struct utsname systemInfo;
		uname(&systemInfo);
		NSString *modelName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
		if ([modelName hasPrefix:@"iPod"]) {
			void *lib = dlopen("/System/Library/PrivateFrameworks/Preferences.framework/Preferences", RTLD_LAZY);
			if (lib)
				SystemHasCapabilities = (BOOL (*)(NSArray *))dlsym(lib, "SystemHasCapabilities");
			if (SystemHasCapabilities)
				MSHookFunction(SystemHasCapabilities, MSHake(SystemHasCapabilities));
			dlopen("/System/Library/PreferenceBundles/KeyboardSettings.bundle/KeyboardSettings", RTLD_LAZY);
			%init(Pref);
		}
	}
}