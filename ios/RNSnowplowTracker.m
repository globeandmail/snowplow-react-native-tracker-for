#import "RNSnowplowTracker.h"
#import <SnowplowTracker/SPTracker.h>
#import <SnowplowTracker/SPEmitter.h>
#import <SnowplowTracker/SPEvent.h>
#import <SnowplowTracker/SPSelfDescribingJson.h>
#import <SnowplowTracker/SPSubject.h>

@implementation RNSnowplowTracker

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(initialize
                  :(nonnull NSString *)endpoint
                  :(nonnull NSString *)method
                  :(nonnull NSString *)protocol
                  :(nonnull NSString *)namespace
                  :(nonnull NSString *)appId
                  :(NSDictionary *)options
                  //:(BOOL *)autoScreenView
                  //:(BOOL *)setPlatformContext
                  //:(BOOL *)setGeoLocationContext
                  //:(BOOL *)setBase64Encoded
                  //:(BOOL *)setApplicationContext
                  //:(BOOL *)setLifecycleEvents
                  //:(BOOL *)setScreenContext
                  //:(BOOL *)setInstallEvent
                  //:(BOOL *)setExceptionEvents
                  //:(BOOL *)setSessionContext
                  //:(INT *)setForegroundTimeout
                  //:(INT *)setBackgroundTimeout
                  //:(STRING *)userId
                ) {
    BOOL setPlatformContext = NO;
    BOOL setGeoLocationContext = NO;
    if (options[@"setPlatformContext"] == @YES ) setPlatformContext = YES;
    if (options[@"setGeoLocationContext"] == @YES ) setGeoLocationContext = YES;
    SPSubject *subject = [[SPSubject alloc] initWithPlatformContext:setPlatformContext andGeoContext:setGeoLocationContext];
    if (options[@"userId"] != nil) {
            [subject setUserId:options[@"userId"]];
    }
    if (options[@"screenWidth"] != nil && options[@"screenHeight"] != nil) {
        [subject setResolutionWithWidth:[options[@"screenWidth"] integerValue] andHeight:[options[@"screenHeight"] integerValue]];
    }
    if (options[@"colorDepth"] != nil) {
        [subject setColorDepth:[options[@"colorDepth"] integerValue]];
    }
    if (options[@"timezone"] != nil) {
        [subject setTimezone:options[@"timezone"]];
    }
    if (options[@"language"] != nil) {
        [subject setLanguage:options[@"language"]];
    }
    if (options[@"ipAddress"] != nil) {
        [subject setIpAddress:options[@"ipAddress"]];
    }
    if (options[@"useragent"] != nil) {
        [subject setUseragent:options[@"useragent"]];
    }
    if (options[@"networkUserId"] != nil) {
        [subject setNetworkUserId:options[@"networkUserId"]];
    }
    if (options[@"domainUserId"] != nil) {
        [subject setDomainUserId:options[@"domainUserId"]];
    }
    
    SPEmitter *emitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setUrlEndpoint:options[@"endpoint"]];
        [builder setHttpMethod:([@"post" caseInsensitiveCompare:options[@"method"]] == NSOrderedSame) ? SPRequestPost : SPRequestGet];
        [builder setProtocol:([@"https" caseInsensitiveCompare:options[@"protocol"]] == NSOrderedSame) ? SPHttps : SPHttp];
    }];

    self.tracker = [SPTracker build:^(id<SPTrackerBuilder> builder) {
        [builder setEmitter:emitter];
        [builder setAppId:appId];
        // setBase64Encoded
        if (options[@"setBase64Encoded"] == @YES ) {
            [builder setBase64Encoded:YES];
        }else [builder setBase64Encoded:NO];
        [builder setTrackerNamespace:namespace];
        [builder setAutotrackScreenViews:options[@"autoScreenView"]];
        // setApplicationContext
        if (options[@"setApplicationContext"] == @YES ) {
            [builder setApplicationContext:YES];
        }else [builder setApplicationContext:NO];
        // setSessionContextui
        if (options[@"setSessionContext"] == @YES ) {
            [builder setSessionContext:YES];
            if (options[@"checkInterval"] != nil) {
                [builder setCheckInterval:[options[@"checkInterval"] integerValue]];
            }else [builder setCheckInterval:15];
            if (options[@"foregroundTimeout"] != nil) {
                 [builder setSessionContext:[options[@"foregroundTimeout"] integerValue]];
            }else [builder setForegroundTimeout:600];
            if (options[@"backgroundTimeout"] != nil) {
                 [builder setSessionContext:[options[@"backgroundTimeout"] integerValue]];
            }else [builder setBackgroundTimeout:300];
        }else [builder setSessionContext:NO];
        // setLifecycleEvents
        if (options[@"setLifecycleEvents"] == @YES ) {
            [builder setLifecycleEvents:YES];
        }else [builder setLifecycleEvents:NO];
        // setScreenContext
        if (options[@"setScreenContext"] == @YES ) {
            [builder setScreenContext:YES];
        }else [builder setScreenContext:NO];
        //setInstallEvent
        if (options[@"setInstallEvent"] == @YES ) {
            [builder setInstallEvent:YES];
        }else [builder setInstallEvent:NO];
        //setExceptionEvents
        if (options[@"setExceptionEvents"] == @YES ) {
            [builder setExceptionEvents:YES];
        }else [builder setExceptionEvents:NO];
        [builder setSubject:subject];
        [builder setSessionContext:[options[@"sessionContext"] boolValue]];
        [builder setCheckInterval:[options[@"checkInterval"] integerValue]];
        [builder setForegroundTimeout:[options[@"foregroundTimeout"] integerValue]];
        [builder setBackgroundTimeout:[options[@"backgroundTimeout"] integerValue]];
    }];

    if (self.tracker) {
        resolve(@YES);
    } else {
        NSError * error = [NSError errorWithDomain:@"SnowplowTracker" code:200 userInfo:nil];
        return reject(@"ERROR", @"SnowplowTracker: initialize() method - tracker initialisation failed", error);
    }
}

RCT_EXPORT_METHOD(setSubjectData :(NSDictionary *)options
                                :rejecter:(RCTPromiseRejectBlock)reject) {

    // the readability we achieved elsewere by using similar patterns to android is not possible here.
    NSString *userId = options[@"userId"];
    NSString *timezone = options[@"timezone"];
    NSString *language = options[@"language"];
    NSString *ipAddress = options[@"ipAddress"];
    NSString *useragent = options[@"useragent"];
    NSString *networkUserId = options[@"networkUserId"];
    NSString *domainUserId = options[@"domainUserId"];

    NSNumber *screenWidth = options[@"screenWidth"];
    NSNumber *screenHeight = options[@"screenHeight"];
    NSNumber *viewportWidth = options[@"viewportWidth"];
    NSNumber *viewportHeight = options[@"viewportHeight"];
    NSNumber *colorDepth = options[@"colorDepth"];

    if (userId) {
        NSString *newUserId = [[NSNull null] isEqual:userId] ? nil : userId;
        [self.tracker.subject setUserId:newUserId];
    }

    if (timezone) {
        NSString *newTimezone = [[NSNull null] isEqual:timezone] ? nil : timezone;
        [self.tracker.subject setTimezone:newTimezone];
    }

    if (ipAddress) {
        NSString *newIpAddress = [[NSNull null] isEqual:ipAddress] ? nil : ipAddress;
        [self.tracker.subject setIpAddress:newIpAddress];
    }

    if (language) {
        NSString *newLanguage = [[NSNull null] isEqual:language] ? nil : language;
        [self.tracker.subject setLanguage:newLanguage];
    }

    if (useragent) {
        NSString *newUseragent = [[NSNull null] isEqual:useragent] ? nil : useragent;
        [self.tracker.subject setUseragent:newUseragent];
    }

    if (networkUserId) {
        NSString *newNetworkUserId = [[NSNull null] isEqual:networkUserId] ? nil : networkUserId;
        [self.tracker.subject setNetworkUserId:newNetworkUserId];
    }

    if (domainUserId) {
        NSString *newDomainUserId = [[NSNull null] isEqual:domainUserId] ? nil : domainUserId;
        [self.tracker.subject setDomainUserId:newDomainUserId];
    }

    if (screenWidth && screenHeight) {
        if ([[NSNull null] isEqual:screenWidth] || [[NSNull null] isEqual:screenHeight]) {
            NSError * error = [NSError errorWithDomain:@"SnowplowTracker" code:100 userInfo:nil];
            return reject(@"ERROR", @"SnowplowTracker: setSubjectData() method -  screenWidth and screenHeight cannot be null", error);
        } else {
            [self.tracker.subject setResolutionWithWidth:[screenWidth integerValue] andHeight:[screenHeight integerValue]];
        }
    }

    if (viewportWidth && viewportHeight) {
        if ([[NSNull null] isEqual:viewportWidth] || [[NSNull null] isEqual:viewportHeight]) {
            NSError * error = [NSError errorWithDomain:@"SnowplowTracker" code:100 userInfo:nil];
            return reject(@"ERROR", @"SnowplowTracker: setSubjectData() method -  viewportWidth and viewportHeight cannot be null", error);
        } else {
            [self.tracker.subject setViewPortWithWidth:[viewportWidth integerValue] andHeight:[viewportHeight integerValue]];
        }
    }

    if (colorDepth != nil) {
        if ([[NSNull null] isEqual:colorDepth]) {
            NSError * error = [NSError errorWithDomain:@"SnowplowTracker" code:100 userInfo:nil];
            return reject(@"ERROR", @"SnowplowTracker: setSubjectData() method -  colorDepth cannot be null", error);
        } else {
            [self.tracker.subject setColorDepth:[colorDepth integerValue]];
        }
    }
}

RCT_EXPORT_METHOD(trackSelfDescribingEvent
                  :(nonnull SPSelfDescribingJson *)event
                  :(NSArray<SPSelfDescribingJson *> *)contexts) {

    SPUnstructured * unstructEvent = [SPUnstructured build:^(id<SPUnstructuredBuilder> builder) {
        [builder setEventData:event];
        if (contexts) {
            [builder setContexts:[[NSMutableArray alloc] initWithArray:contexts]];
        }
    }];

    [self.tracker trackUnstructuredEvent:unstructEvent];
}

RCT_EXPORT_METHOD(trackStructuredEvent
                  :(NSDictionary *)details
                  :(NSArray<SPSelfDescribingJson *> *)contexts) {

    SPStructured * structuredEvent = [SPStructured build:^(id<SPStructuredBuilder> builder) {
        [builder setCategory:details[@"category"]];
        [builder setAction:details[@"action"]];
        if (details[@"label"] != nil) {
            [builder setLabel:details[@"label"]];
        }
        if (details[@"property"] != nil) {
            [builder setProperty:details[@"property"]];
        }
        // doubleValue cannot be NSNull, and falsey value evaluates to 0 in objective-c. Only set 'value' parameter where neither are the case.
        if (details[@"value"] != (id)[NSNull null] && details[@"value"] != nil) {
            [builder setValue:[details[@"value"] doubleValue]];
        }
        if (contexts) {
            [builder setContexts:[[NSMutableArray alloc] initWithArray:contexts]];
        }
    }];

    [self.tracker trackStructuredEvent:structuredEvent];
}

RCT_EXPORT_METHOD(trackScreenViewEvent
                  :(NSDictionary *)details
                  :(NSArray<SPSelfDescribingJson *> *)contexts) {

    SPScreenView * screenViewEvent = [SPScreenView build:^(id<SPScreenViewBuilder> builder) {
        [builder setName:details[@"screenName"]];

        // screenType must not be NSNull.
        if (details[@"screenType"] != (id)[NSNull null] && details[@"screenType"] != nil) [builder setType:details[@"screenType"]];
        if (details[@"transitionType"] != nil) [builder setTransitionType:details[@"transitionType"]];
        if (contexts) {
            [builder setContexts:[[NSMutableArray alloc] initWithArray:contexts]];
        }
      }];

      [self.tracker trackScreenViewEvent:screenViewEvent];
}

RCT_EXPORT_METHOD(trackPageViewEvent
                  :(NSDictionary *)details
                  :(NSArray<SPSelfDescribingJson *> *)contexts) {

    SPPageView * pageViewEvent = [SPPageView build:^(id<SPPageViewBuilder> builder) {
        [builder setPageUrl:details[@"pageUrl"]];
        if (details[@"pageTitle"] != nil) [builder setPageTitle:details[@"pageTitle"]];
        if (details[@"pageReferrer"] != nil) [builder setReferrer:details[@"pageReferrer"]];
        if (contexts) {
            [builder setContexts:[[NSMutableArray alloc] initWithArray:contexts]];
        }
    }];
    [self.tracker trackPageViewEvent:pageViewEvent];
}

RCT_EXPORT_METHOD(trackPageView
                  :(nonnull NSString *)pageUrl // required (non-empty string)
                  :(NSString *)pageTitle
                  :(NSString *)pageReferrer
                  :(NSArray<SPSelfDescribingJson *> *)contexts) {
    SPPageView * trackerEvent = [SPPageView build:^(id<SPPageViewBuilder> builder) {
        [builder setPageUrl:pageUrl];
        if (pageTitle != nil) [builder setPageTitle:pageTitle];
        if (pageReferrer != nil) [builder setReferrer:pageReferrer];
        if (contexts) {
            [builder setContexts:[[NSMutableArray alloc] initWithArray:contexts]];
        }
    }];
    [self.tracker trackPageViewEvent:trackerEvent];
}

RCT_EXPORT_METHOD(setUserId
                  :(nonnull NSString *)userId // required (non-empty string)
                ) {
    SPSubject * s = self.tracker.subject;
    if (userId != nil) {
        [s setUserId:userId];
        [self.tracker setSubject:s];
    }
}

RCT_EXPORT_METHOD(getSessionUserId:(RCTPromiseResolveBlock)resolve 
                  rejecter:(RCTPromiseRejectBlock)reject
                 ) {
  NSError *error;
  NSString *contents = [self.tracker getSessionUserId];
  if (contents) {
    resolve(contents);
  } else {
    reject(@"data_issue", @"Cannot obtain SESSION_USER_ID", error);
  }
}

RCT_EXPORT_METHOD(getSessionId:(RCTPromiseResolveBlock)resolve 
                  rejecter:(RCTPromiseRejectBlock)reject
                 ) {
  NSError *error;
  NSString *contents = [self.tracker getSessionId];
  if (contents) {
    resolve(contents);
  } else {
    reject(@"data_issue", @"Cannot obtain SESSION_ID", error);
  }
}

RCT_EXPORT_METHOD(getSessionIndex:(RCTPromiseResolveBlock)resolve 
                  rejecter:(RCTPromiseRejectBlock)reject
                 ) {
  NSError *error;
  NSInteger contents = [self.tracker getSessionIndex];
  NSNumber *val= [NSNumber numberWithInteger:contents];
  if (val) {
    resolve(val);
  } else {
    reject(@"data_issue", @"Cannot obtain SESSION_INDEX", error);
  }
}

@end
