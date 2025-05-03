class TrackingManager {
  static final TrackingManager _instance = TrackingManager._internal();
  factory TrackingManager() => _instance;
  TrackingManager._internal();

  final Set<int> _trackedUserIds = {};

  bool isTracking(int userId) => _trackedUserIds.contains(userId);

  void startTracking(int userId) => _trackedUserIds.add(userId);

  void stopTracking(int userId) => _trackedUserIds.remove(userId);
}
