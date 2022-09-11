#import "SceneState.h"
#import <CarPlay/CarPlay.h>

@implementation SceneState

RCT_EXPORT_MODULE()

- (id)init {
  self = [SceneState alloc];
    
    if(@available(iOS 13.0, *)){
    
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sceneWillConnect:) name:UISceneWillConnectNotification object:nil];
        
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sceneDidEnterBackground:) name:UISceneDidEnterBackgroundNotification object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sceneWillEnterForeground:) name:UISceneWillEnterForegroundNotification object:nil];
  }
    
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
    
    return @{@"state": state, @"isCarPlay": @([scene isKindOfClass:CPTemplateApplicationScene.class])};

}

- (void)sceneWillConnect:(NSNotification *)sender{
    UIScene *scene = (UIScene*)sender.object;
    [self sendEventWithName:@"onSceneStateChange" body:@{@"state": @"connect", @"isCarPlay": @([scene isKindOfClass:CPTemplateApplicationScene.class])}];
}


- (void)sceneDidEnterBackground:(NSNotification *)sender{
    UIScene *scene = (UIScene*)sender.object;
    [self sendEventWithName:@"onSceneStateChange" body:@{@"state": @"background", @"isCarPlay": @([scene isKindOfClass:CPTemplateApplicationScene.class])}];
}

- (void)sceneWillEnterForeground:(NSNotification *)sender{
    UIScene *scene = (UIScene*)sender.object;
    [self sendEventWithName:@"onSceneStateChange" body:@{@"state": @"active", @"isCarPlay": @([scene isKindOfClass:CPTemplateApplicationScene.class])}];
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
