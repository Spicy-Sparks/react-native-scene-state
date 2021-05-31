import {
  EmitterSubscription,
  NativeEventEmitter,
  NativeModules,
} from 'react-native';

type SceneStateStateType = "active" | "inactive" | "background"

type SceneStateType = {
  getCurrentState(): Promise<SceneStateStateType>;
  addEventListener(event: string, listener: (event: any) => any): EmitterSubscription;
  removeEventListener(listener: EmitterSubscription): void;
  removeAllListeners(event: string): void;
};

const { SceneState } = NativeModules;

const emitter = new NativeEventEmitter(SceneState);

SceneState.addEventListener = function (
  event: string,
  listener: (event: any) => any
): EmitterSubscription {
  return emitter.addListener(event, listener);
};

SceneState.removeEventListener = function (listener: EmitterSubscription) {
  return emitter.removeSubscription(listener);
};

SceneState.removeAllListeners = function (event: string) {
  return emitter.removeAllListeners(event);
};

export default SceneState as SceneStateType;
