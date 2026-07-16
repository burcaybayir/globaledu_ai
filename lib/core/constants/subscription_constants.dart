class SubscriptionConstants {
  SubscriptionConstants._();

  // Plan IDs (RevenueCat)
  static const String freePlanId = 'free';
  static const String proPlanId = 'pro_monthly';
  static const String proAnnualPlanId = 'pro_annual';
  static const String premiumPlanId = 'premium_monthly';
  static const String premiumAnnualPlanId = 'premium_annual';

  // Entitlement IDs
  static const String proEntitlement = 'pro_access';
  static const String premiumEntitlement = 'premium_access';

  // Pricing
  static const double proMonthlyPrice = 9.99;
  static const double proAnnualPrice = 99.99;
  static const double premiumMonthlyPrice = 19.99;
  static const double premiumAnnualPrice = 199.99;

  // Feature Flags
  static const Map<String, List<String>> planFeatures = {
    freePlanId: [
      '10 AI messages/day',
      'Basic university search',
      '2 application tracking',
      'General visa guidance',
      '100MB document storage',
    ],
    proPlanId: [
      '100 AI messages/day',
      'Advanced search & filters',
      '10 application tracking',
      '5 AI document reviews/month',
      'AI-powered scholarship matching',
      'Country-specific visa guidance',
      '1GB document storage',
    ],
    premiumPlanId: [
      'Unlimited AI messages',
      'AI-powered university matching',
      'Unlimited application tracking',
      'Unlimited AI document reviews',
      'Priority scholarship alerts',
      'Personalized visa guidance',
      'Interview preparation AI',
      '10GB document storage',
      'Priority support',
    ],
  };
}
