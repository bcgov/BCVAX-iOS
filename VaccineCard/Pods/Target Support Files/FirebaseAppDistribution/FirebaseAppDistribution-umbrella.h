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

#import "FIRAppDistribution.h"
#import "FIRAppDistributionRelease.h"
#import "FirebaseAppDistribution.h"

FOUNDATION_EXPORT double FirebaseAppDistributionVersionNumber;
FOUNDATION_EXPORT const unsigned char FirebaseAppDistributionVersionString[];

