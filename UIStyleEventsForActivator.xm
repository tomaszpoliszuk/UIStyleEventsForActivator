#import <Foundation/Foundation.h>
#import <libactivator/libactivator.h>
#import <UIKit/UIKit.h>

#include <dispatch/dispatch.h>
#include <objc/runtime.h>

#define LASendEventWithName(eventName) \
	[LASharedActivator sendEventToListener:[LAEvent eventWithName:eventName mode:[LASharedActivator currentEventMode]]]

static NSString *UIStyleChanged = @"UI Style changed";
static NSString *DarkModeActivated = @"Dark Mode activated";
static NSString *LightModeActivated = @"Light Mode activated";


@interface AlertDataSource : NSObject <LAEventDataSource>
+ (id)sharedInstance;
@end

@implementation AlertDataSource
+ (id)sharedInstance {
	static id sharedInstance = nil;
	static dispatch_once_t token = 0;
	dispatch_once(&token, ^{
		sharedInstance = [self new];
	});
	return sharedInstance;
}
+ (void)load {
	[self sharedInstance];
}
- (id)init {
	if (self = [super init]) {
		[LASharedActivator registerEventDataSource:self forEventName:UIStyleChanged];
		[LASharedActivator registerEventDataSource:self forEventName:DarkModeActivated];
		[LASharedActivator registerEventDataSource:self forEventName:LightModeActivated];
	}
	return self;
}
- (NSString *)localizedTitleForEventName:(NSString *)eventName {
	if ([eventName isEqualToString:UIStyleChanged]) {
		return @"UI Style changed";
	} else if ([eventName isEqualToString:DarkModeActivated]) {
		return @"Dark Mode activated";
	} else if ([eventName isEqualToString:LightModeActivated]) {
		return @"Light Mode activated";
	}
	return @" ";
}
- (NSString *)localizedGroupForEventName:(NSString *)eventName {
	return @"UI Style";
}
- (NSString *)localizedDescriptionForEventName:(NSString *)eventName {
	if ([eventName isEqualToString:UIStyleChanged]) {
		return @"Triggered when UI Style is changed";
	} else if ([eventName isEqualToString:DarkModeActivated]) {
		return @"Triggered when Dark Mode is activated";
	} else if ([eventName isEqualToString:LightModeActivated]) {
		return @"Triggered when Light Mode is activated";
	}
	return @" ";
}
- (void)dealloc {
	[LASharedActivator unregisterEventDataSourceWithEventName:UIStyleChanged];
	[LASharedActivator unregisterEventDataSourceWithEventName:DarkModeActivated];
	[LASharedActivator unregisterEventDataSourceWithEventName:LightModeActivated];
	[super dealloc];
}
@end


%hook UIUserInterfaceStyleArbiter
- (void)userInterfaceStyleModeDidChange:(id)arg1 {
	%orig;
	LASendEventWithName(UIStyleChanged);
}
- (long long)_proposedStyleForCurrentMode {
	long long nextMode = %orig;
	if ( nextMode == 2 ) {
		LASendEventWithName(DarkModeActivated);
	} else {
		LASendEventWithName(LightModeActivated);
	}
	return nextMode;
}
%end
