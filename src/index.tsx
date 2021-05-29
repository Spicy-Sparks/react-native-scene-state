import { NativeModules } from 'react-native';

type SceneStateType = {
  multiply(a: number, b: number): Promise<number>;
};

const { SceneState } = NativeModules;

export default SceneState as SceneStateType;
