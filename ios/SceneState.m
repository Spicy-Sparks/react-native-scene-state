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


- (NSDictionary *) parseSceneState:(UIScene*)scene {
    NSString *state = nil;
    switch (scene.activationState) {
        case UISceneActivationStateUnattached:
            state = @"background";
        case UISceneActivationStateForegroundActive:
            state = @"active";
        case UISceneActivationStateForegroundInactive:
            state = @"inactive";
        case UISceneActivationStateBackground:
            state = @"background";
        default:
            state = @"active";
    }
    
    return @{@"state": state, @"scene": scene.title};
    
    /*UISceneActivationStateUnattached = -1,
     UISceneActivationStateForegroundActive,
     UISceneActivationStateForegroundInactive,
     UISceneActivationStateBackground*/
}


/*+ (void) updateSceneState:(BOOL)isInBackground API_AVAILABLE(ios(13.0)){
    
    //[self parseSceneState:getPhoneScene().activationState];


}*/

- (void)sceneWillConnect:(NSNotification *)sender{
    UIScene *scene = (UIScene*)sender.object;
    [self sendEventWithName:@"onSceneStateChange" body:@{@"state": @"connect", @"scene": scene.title}];
}


- (void)sceneDidEnterBackground:(NSNotification *)sender{    UIScene *scene = (UIScene*)sender.object;
    [self sendEventWithName:@"onSceneStateChange" body:@{@"state": @"background", @"scene": scene.title}];
}

- (void)sceneWillEnterForeground:(NSNotification *)sender{
    UIScene *scene = (UIScene*)sender.object;
    [self sendEventWithName:@"onSceneStateChange" body:@{@"state": @"active", @"scene": scene.title}];
}

RCT_REMAP_METHOD(updateSceneState,
                 isInBackground:BOOL
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendEventWithName:@"onSceneStateChange" body:[self parseSceneState:UIApplication.sharedApplication.delegate.window.windowScene]];
    });
}

RCT_REMAP_METHOD(getCurrentState,
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        /*[self sendEventWithName:@"onSceneStateChange" body:[self parseSceneState:UIApplication.sharedApplication.delegate.window.windowScene.activationState]];*/
        resolve([self parseSceneState:UIApplication.sharedApplication.delegate.window.windowScene]);
    });
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"onSceneStateChange"];
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}
@end
