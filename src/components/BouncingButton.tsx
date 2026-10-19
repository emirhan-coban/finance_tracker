import React, { useRef } from 'react';
import {
  Animated,
  Pressable,
  PressableProps,
  StyleProp,
  ViewStyle,
  GestureResponderEvent,
} from 'react-native';
import * as Haptics from 'expo-haptics';

const AnimatedPressable = Animated.createAnimatedComponent(Pressable);

export interface BouncingButtonProps extends Omit<PressableProps, 'style'> {
  scaleTo?: number;
  enableHaptic?: boolean;
  hapticStyle?: Haptics.ImpactFeedbackStyle;
  style?: StyleProp<ViewStyle>;
  children?: React.ReactNode;
}

export function BouncingButton({
  scaleTo = 0.96,
  enableHaptic = true,
  hapticStyle = Haptics.ImpactFeedbackStyle.Light,
  onPress,
  onPressIn,
  onPressOut,
  style,
  children,
  ...props
}: BouncingButtonProps) {
  const scaleAnim = useRef(new Animated.Value(1)).current;

  const handlePressIn = (e: GestureResponderEvent) => {
    Animated.spring(scaleAnim, {
      toValue: scaleTo,
      useNativeDriver: true,
      speed: 40,
      bounciness: 4,
    }).start();
    onPressIn?.(e);
  };

  const handlePressOut = (e: GestureResponderEvent) => {
    Animated.spring(scaleAnim, {
      toValue: 1,
      useNativeDriver: true,
      speed: 35,
      bounciness: 4,
    }).start();
    onPressOut?.(e);
  };

  const handlePress = (e: GestureResponderEvent) => {
    if (enableHaptic) {
      Haptics.impactAsync(hapticStyle).catch(() => {});
    }
    onPress?.(e);
  };

  return (
    <AnimatedPressable
      onPress={handlePress}
      onPressIn={handlePressIn}
      onPressOut={handlePressOut}
      style={[{ transform: [{ scale: scaleAnim }] }, style]}
      {...props}
    >
      {children}
    </AnimatedPressable>
  );
}

export default BouncingButton;
