#import "SceneState.h"
#import "RCTUtils.h"

@implementation SceneState

RCT_EXPORT_MODULE()

- (id)init {
  self = [SceneState alloc];
    
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sceneWillConnect:) name:UISceneWillConnectNotification object:nil];
    
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sceneDidEnterBackground:) name:UISceneDidEnterBackgroundNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sceneWillEnterForeground:) name:UISceneWillEnterForegroundNotification object:nil];
  return self;
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}


- (NSString *) parseSceneState:(NSInteger)sceneState {
    switch (sceneState) {
        case UISceneActivationStateUnattached:
            return @"background";
        case UISceneActivationStateForegroundActive:
            return @"active";
        case UISceneActivationStateForegroundInactive:
            return @"inactive";
        case UISceneActivationStateBackground:
            return @"background";
        default:
            return @"active";
    }
    
    /*UISceneActivationStateUnattached = -1,
     UISceneActivationStateForegroundActive,
     UISceneActivationStateForegroundInactive,
     UISceneActivationStateBackground*/
}


/*+ (void) updateSceneState:(BOOL)isInBackground API_AVAILABLE(ios(13.0)){
    
    //[self parseSceneState:getPhoneScene().activationState];


}*/

- (void)sceneWillConnect:(NSNotification *)sender{
    [self sendEventWithName:@"onSceneWillConnect" body:@"background"];
}


- (void)sceneDidEnterBackground:(NSNotification *)sender{
    [self sendEventWithName:@"onSceneStateChange" body:@"background"];
}

- (void)sceneWillEnterForeground:(NSNotification *)sender{
    [self sendEventWithName:@"onSceneStateChange" body:@"active"];
}

RCT_REMAP_METHOD(updateSceneState,
                 isInBackground:BOOL
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    
  if(getPhoneScene() == nil)
      return resolve(nil);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendEventWithName:@"onSceneStateChange" body:[self parseSceneState:getPhoneScene().activationState]];
    });
}

RCT_REMAP_METHOD(getCurrentState,
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    
  if(getPhoneScene() == nil)
      return resolve(nil);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendEventWithName:@"onSceneStateChange" body:[self parseSceneState:getPhoneScene().activationState]];
        resolve([self parseSceneState:getPhoneScene().activationState]);
    });
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"onSceneWillConnect", @"onSceneStateChange"];
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}
@end
