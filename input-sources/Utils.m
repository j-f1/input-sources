#import "Utils.h"

// Written in Objective-C to avoid issues: https://stackoverflow.com/q/59521506/5244995

NSString *getStringProp(TISInputSourceRef src, CFStringRef prop) {
    return (__bridge NSString *)TISGetInputSourceProperty(src, prop);
}

BOOL getBoolProp(TISInputSourceRef src, CFStringRef prop) {
    return ((__bridge NSNumber *)TISGetInputSourceProperty(src, prop)).boolValue;
}
