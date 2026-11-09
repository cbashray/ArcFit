/// App Constants for ArcFit
class AppConstants {
  // App info
  static const String appName = 'ArcFit';
  static const String appVersion = '1.0.0';

  // Feature flags
  static const bool enableFormCorrection = false; // Phase 3
  static const bool enableNutrition = true; // Phase 4
  static const bool enableAdaptiveWorkout = true; // Phase 2

  // Default values
  static const int defaultWorkoutDuration = 60; // minutes

  // UI Constants
  static const Duration quickAnimationDuration = Duration(milliseconds: 150);
  static const Duration normalAnimationDuration = Duration(milliseconds: 250);
  static const Duration slowAnimationDuration = Duration(milliseconds: 350);

  // Exercise database defaults
  static const int defaultSets = 3;
  static const int defaultReps = 10;
  static const int defaultRestSeconds = 60;
}