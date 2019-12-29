#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

NSString *getStringProp(TISInputSourceRef src, CFStringRef prop);
BOOL getBoolProp(TISInputSourceRef src, CFStringRef prop);
