class AppConstants {
  AppConstants._();

  // LLM
  static const String anthropicBaseUrl = 'https://api.anthropic.com/v1';
  static const String initialPlanModel = 'claude-sonnet-4-5';
  static const String weeklyAdjustModel = 'claude-haiku-4-5';
  static const int maxMonthlyLlmCalls = 5; // 1 initial + 4 weekly
  static const int maxOutputTokens = 4096;

  // Plan
  static const int planWeeks = 4;
  static const int maxExercisesPerDay = 8;
  static const int minExercisesPerDay = 3;

  // Storage keys
  static const String keyApiKey = 'anthropic_api_key';
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyLlmCallsThisMonth = 'llm_calls_this_month';
  static const String keyLlmCallsResetDate = 'llm_calls_reset_date';
  static const String keySubscriptionActive = 'subscription_active';
  static const String keySubscriptionExpiry = 'subscription_expiry';
  static const String keyLastWeeklyAdjust = 'last_weekly_adjust';

  // In-app purchase
  static const String subscriptionId = 'com.recoveryfit.app.monthly';
  static const int subscriptionPriceKrw = 2900;

  // Notification
  static const int workoutReminderNotifId = 1001;
  static const int weeklyAdjustNotifId = 1002;

  // Free trial
  static const int freeTrialDays = 7;

  // Medical disclaimer
  static const String disclaimer =
      '⚠️ RecoveryFit은 의료기기가 아닙니다. 제공되는 운동 플랜은 일반적인 건강 정보를 위한 것이며 의학적 진단·치료·처방을 대체하지 않습니다. '
      '부상·통증이 있는 경우 반드시 전문의와 상담 후 운동을 시작하세요.';
}
