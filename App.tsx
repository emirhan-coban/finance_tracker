import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import { ThemeProvider, useTheme } from './src/context/ThemeContext';
import { ExpenseProvider } from './src/context/ExpenseContext';
import DashboardScreen from './src/screens/DashboardScreen';
import AllExpensesScreen from './src/screens/AllExpensesScreen';
import AddExpenseScreen from './src/screens/AddExpenseScreen';
import SubscriptionsScreen from './src/screens/SubscriptionsScreen';

const Stack = createNativeStackNavigator();

function NavigationRoot() {
  const { isDark, theme } = useTheme();

  return (
    <>
      <StatusBar style={isDark ? 'light' : 'dark'} />
      <NavigationContainer
        theme={{
          dark: isDark,
          colors: {
            primary: theme.accent,
            background: theme.bg,
            card: theme.surface,
            text: theme.text,
            border: theme.border,
            notification: theme.accent,
          },
          fonts: {
            regular: { fontFamily: 'System', fontWeight: '400' },
            medium: { fontFamily: 'System', fontWeight: '500' },
            bold: { fontFamily: 'System', fontWeight: '700' },
            heavy: { fontFamily: 'System', fontWeight: '900' },
          },
        }}
      >
        <Stack.Navigator
          screenOptions={{
            headerShown: false,
            animation: 'slide_from_right',
          }}
        >
          <Stack.Screen name="Dashboard" component={DashboardScreen} />
          <Stack.Screen name="AllExpenses" component={AllExpensesScreen} />
          <Stack.Screen name="Subscriptions" component={SubscriptionsScreen} />
          <Stack.Screen
            name="AddExpense"
            component={AddExpenseScreen}
            options={{ animation: 'slide_from_bottom' }}
          />
        </Stack.Navigator>
      </NavigationContainer>
    </>
  );
}

export default function App() {
  return (
    <SafeAreaProvider>
      <ThemeProvider>
        <ExpenseProvider>
          <NavigationRoot />
        </ExpenseProvider>
      </ThemeProvider>
    </SafeAreaProvider>
  );
}
