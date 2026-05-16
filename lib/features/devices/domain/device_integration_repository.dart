import 'fitness_provider.dart';

class DeviceConnectionInfo {
  const DeviceConnectionInfo({
    required this.provider,
    required this.available,
    required this.connected,
    required this.permissionStatus,
    required this.isPreviewMode,
    this.message,
  });

  final FitnessProviderType provider;
  final bool available;
  final bool connected;
  final String permissionStatus;
  final bool isPreviewMode;
  final String? message;
}

abstract class DeviceIntegrationRepository {
  Future<DeviceConnectionInfo> getConnectionInfo(FitnessProviderType provider);
  Future<DeviceConnectionInfo> connect(FitnessProviderType provider);
}
