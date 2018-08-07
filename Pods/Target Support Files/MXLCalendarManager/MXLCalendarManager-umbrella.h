#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MXLCalendar.h"
#import "MXLCalendarAttendee.h"
#import "MXLCalendarEvent.h"
#import "MXLCalendarManager.h"
#import "NSTimeZone+ProperAbbreviation.h"

FOUNDATION_EXPORT double MXLCalendarManagerVersionNumber;
FOUNDATION_EXPORT const unsigned char MXLCalendarManagerVersionString[];

