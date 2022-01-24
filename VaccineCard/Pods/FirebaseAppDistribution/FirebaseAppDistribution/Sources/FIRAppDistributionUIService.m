// Copyright 2019 Google
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "FirebaseAppDistribution/Sources/FIRAppDistributionUIService.h"
#import "FirebaseAppDistribution/Sources/FIRFADLogger.h"
#import "FirebaseAppDistribution/Sources/Public/FirebaseAppDistribution/FIRAppDistribution.h"
#import "FirebaseCore/Sources/Private/FirebaseCoreInternal.h"

#import <AuthenticationServices/AuthenticationServices.h>
#import <SafariServices/SafariServices.h>
#import <UIKit/UIKit.h>

@implementation FIRAppDistributionUIService

API_AVAILABLE(ios(9.0))
SFSafariViewController *_safariVC;

API_AVAILABLE(ios(12.0))
ASWebAuthenticationSession *_webAuthenticationVC;

API_AVAILABLE(ios(11.0))
SFAuthenticationSession *_safariAuthenticationVC;

- (instancetype)init {
  self = [super init];

  self.safariHostingViewController = [[UIViewController alloc] init];

  return self;
}

+ (instancetype)sharedInstance {
  static dispatch_once_t once;
  static FIRAppDistributionUIService *sharedInstance;
  dispatch_once(&once, ^{
    sharedInstance = [[FIRAppDistributionUIService alloc] init];
  });

  return sharedInstance;
}

+ (NSString *)encodedAppId {
  return [[[FIRApp defaultApp] options].googleAppID stringByReplacingOccurrencesOfString:@":"
                                                                              withString:@"-"];
}

+ (NSError *)getAppDistributionError:(FIRAppDistributionError)appDistributionErrorCode {
  NSString *message = appDistributionErrorCode == FIRAppDistributionErrorAuthenticationCancelled
                          ? @"User cancelled sign-in flow"
                          : @"Failed to authenticate the user";
  NSDictionary *userInfo = @{FIRAppDistributionErrorDetailsKey : message};
  return [NSError errorWithDomain:FIRAppDistributionErrorDomain
                             code:appDistributionErrorCode
                         userInfo:userInfo];
}

+ (NSError *_Nullable)mapErrorToAppDistributionError:(NSError *_Nullable)error {
  if (!error) {
    return nil;
  }

  if (@available(iOS 12.0, *)) {
    if ([error code] == ASWebAuthenticationSessionErrorCodeCanceledLogin) {
      return [self getAppDistributionError:FIRAppDistributionErrorAuthenticationCancelled];
    }
  } else if (@available(iOS 11.0, *)) {
    if ([error code] == SFAuthenticationErrorCanceledLogin) {
      return [self getAppDistributionError:FIRAppDistributionErrorAuthenticationCancelled];
    }
  }

  return [self getAppDistributionError:FIRAppDistributionErrorAuthenticationFailure];
}

- (void)appDistributionRegistrationFlow:(NSURL *)URL
                         withCompletion:(void (^)(NSError *_Nullable error))completion {
  NSString *callbackURL =
      [NSString stringWithFormat:@"appdistribution-%@", [[self class] encodedAppId]];

  FIRFADInfoLog(@"Registration URL: %@", URL);
  FIRFADInfoLog(@"Callback URL: %@", callbackURL);

  if (@available(iOS 12.0, *)) {
    ASWebAuthenticationSession *authenticationVC = [[ASWebAuthenticationSession alloc]
              initWithURL:URL
        callbackURLScheme:callbackURL
        completionHandler:^(NSURL *_Nullable callbackURL, NSError *_Nullable error) {
          [self resetUIState];
          [self logRegistrationCompletion:error authType:[ASWebAuthenticationSession description]];
          NSError *_Nullable appDistributionError =
              [[self class] mapErrorToAppDistributionError:error];
          completion(appDistributionError);
        }];

    if (@available(iOS 13.0, *)) {
      authenticationVC.presentationContextProvider = self;
    }

    _webAuthenticationVC = authenticationVC;

    [authenticationVC start];
  } else if (@available(iOS 11.0, *)) {
    _safariAuthenticationVC = [[SFAuthenticationSession alloc]
              initWithURL:URL
        callbackURLScheme:callbackURL
        completionHandler:^(NSURL *_Nullable callbackURL, NSError *_Nullable error) {
          [self resetUIState];
          [self logRegistrationCompletion:error authType:[SFAuthenticationSession description]];
          NSError *_Nullable appDistributionError =
              [[self class] mapErrorToAppDistributionError:error];
          completion(appDistributionError);
        }];

    [_safariAuthenticationVC start];
  } else if (@available(iOS 9.0, *)) {
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:URL];

    safariVC.delegate = self;
    _safariVC = safariVC;
    [self->_safariHostingViewController presentViewController:safariVC animated:YES completion:nil];
    self.registrationFlowCompletion = completion;
  }
}

- (void)showUIAlert:(UIAlertController *)alertController {
  [self initializeUIState];
  [self.window.rootViewController presentViewController:alertController
                                               animated:YES
                                             completion:nil];
}

- (void)showUIAlertWithCompletion:(FIRFADUIActionCompletion)completion {
  UIAlertController *alert = [UIAlertController
      alertControllerWithTitle:NSLocalizedString(
                                   @"Enable new build alerts",
                                   @"Title for App Distribution New Build Alerts UIAlert.")
                       message:NSLocalizedString(
                                   @"Get in-app alerts when new builds are ready to test.",
                                   @"Description for enabling new build alerts will do.")
                preferredStyle:UIAlertControllerStyleAlert];

  UIAlertAction *yesButton = [UIAlertAction
      actionWithTitle:NSLocalizedString(@"Turn on", @"Button for turning on new build alerts.")
                style:UIAlertActionStyleDefault
              handler:^(UIAlertAction *action) {
                completion(YES);
              }];

  UIAlertAction *noButton = [UIAlertAction
      actionWithTitle:NSLocalizedString(@"Not now",
                                        @"Button for dismissing the new build alerts UIAlert")
                style:UIAlertActionStyleDefault
              handler:^(UIAlertAction *action) {
                [self resetUIState];
                completion(NO);
              }];

  [alert addAction:noButton];
  [alert addAction:yesButton];

  // Create an empty window + viewController to host the Safari UI.
  [self showUIAlert:alert];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)URL
            options:(NSDictionary<NSString *, id> *)options {
  if (self.registrationFlowCompletion) {
    FIRFADDebugLog(@"Continuing registration flow: %@", [self registrationFlowCompletion]);
    [self resetUIState];
    if (@available(iOS 9.0, *)) {
      [self logRegistrationCompletion:nil authType:[SFSafariViewController description]];
    }
    self.registrationFlowCompletion(nil);
  }
  return NO;
}

- (void)logRegistrationCompletion:(NSError *)error authType:(NSString *)authType {
  if (error) {
    FIRFADErrorLog(@"Failed to complete App Distribution registration flow. Auth type - %@, Error "
                   @"- %@: %ld. Details - %@",
                   authType, [error domain], (long)[error code], [error localizedDescription]);
  } else {
    FIRFADInfoLog(@"App Distribution Registration complete. Auth type - %@", authType);
  }
}

- (void)initializeUIState {
  if (self.window) {
    return;
  }

  if (@available(iOS 13.0, *)) {
    UIWindowScene *foregroundedScene = nil;
    for (UIWindowScene *connectedScene in [UIApplication sharedApplication].connectedScenes) {
      if (connectedScene.activationState == UISceneActivationStateForegroundActive) {
        foregroundedScene = connectedScene;
        break;
      }
    }

    if (foregroundedScene) {
      self.window = [[UIWindow alloc] initWithWindowScene:foregroundedScene];
    } else {
      FIRFADInfoLog(@"No foreground scene found.");
      self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
  } else {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  }
  self.window.rootViewController = self.safariHostingViewController;

  // Place it at the highest level within the stack.
  self.window.windowLevel = +CGFLOAT_MAX;

  // Run it.
  [self.window makeKeyAndVisible];
}

- (void)resetUIState {
  if (self.window) {
    self.window.rootViewController = nil;
    self.window.hidden = YES;
    self.window = nil;
  }

  self.registrationFlowCompletion = nil;

  if (@available(iOS 11.0, *)) {
    _safariAuthenticationVC = nil;
  } else if (@available(iOS 12.0, *)) {
    _webAuthenticationVC = nil;
  } else if (@available(iOS 9.0, *)) {
    _safariVC = nil;
  }
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller NS_AVAILABLE_IOS(9.0) {
  NSError *error =
      [[self class] getAppDistributionError:FIRAppDistributionErrorAuthenticationCancelled];
  [self logRegistrationCompletion:error authType:[SFSafariViewController description]];

  if (self.registrationFlowCompletion) {
    self.registrationFlowCompletion(error);
  }
  [self resetUIState];
}

- (ASPresentationAnchor)presentationAnchorForWebAuthenticationSession:
    (ASWebAuthenticationSession *)session API_AVAILABLE(ios(13.0)) {
  return self.safariHostingViewController.view.window;
}

@end
