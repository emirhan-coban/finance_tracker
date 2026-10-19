import React from 'react';
import { View, StyleSheet, ViewProps } from 'react-native';

interface ResponsiveContainerProps extends ViewProps {
  maxWidth?: number;
  children: React.ReactNode;
}

export default function ResponsiveContainer({
  maxWidth = 640,
  style,
  children,
  ...props
}: ResponsiveContainerProps) {
  return (
    <View style={[styles.outer, style]} {...props}>
      <View style={[styles.inner, { maxWidth }]}>{children}</View>
    </View>
  );
}

const styles = StyleSheet.create({
  outer: {
    flex: 1,
    width: '100%',
    alignItems: 'center',
  },
  inner: {
    flex: 1,
    width: '100%',
  },
});
