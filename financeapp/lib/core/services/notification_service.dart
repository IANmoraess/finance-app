abstract class NotificationService {
  Future<void> initialize();
  Future<void> show({required String title, required String body});
  Future<void> cancel(int id);
}
