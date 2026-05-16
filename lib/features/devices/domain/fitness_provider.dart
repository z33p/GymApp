enum FitnessProviderType { appleHealth, healthConnect, garmin, mock }

extension FitnessProviderTypeX on FitnessProviderType {
  String get value => switch (this) {
        FitnessProviderType.appleHealth => 'apple_health',
        FitnessProviderType.healthConnect => 'health_connect',
        FitnessProviderType.garmin => 'garmin',
        FitnessProviderType.mock => 'mock',
      };

  String get label => switch (this) {
        FitnessProviderType.appleHealth => 'Apple Health',
        FitnessProviderType.healthConnect => 'Health Connect',
        FitnessProviderType.garmin => 'Garmin',
        FitnessProviderType.mock => 'Preview Data',
      };
}
