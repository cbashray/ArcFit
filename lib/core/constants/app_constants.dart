/// App Constants for FitX
class AppConstants {
  // App info
  static const String appName = 'FitX';
  static const String appVersion = '1.0.0';

  // Feature flags
  static const bool enableFormCorrection = false; // Phase 3
  static const bool enableNutrition = false; // Phase 4
  static const bool enableAdaptiveWorkout = true; // Phase 2

  // Default values
  static const int defaultWorkoutDuration = 60; // minutes

  // UI Constants
  static const Duration quickAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);

  // Exercise database defaults
  static const int defaultSets = 3;
  static const int defaultReps = 10;
  static const int defaultRestSeconds = 60;
}
