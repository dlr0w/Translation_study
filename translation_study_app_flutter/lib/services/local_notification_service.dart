// このクラスの責務
// 通知プラグインの初期化
// Android/iOSの通知許可リクエスト
// タイムゾーン初期化
// 毎日20時通知の予約
// 通知タップ時のpayload受け取り
class LocalNotificationService {
    LocalNotificationService._();
    static final LocalNotificationService instance = LocalNotificationService._();
  // 通知プラグインを初期化
  Future<void> initiailze({
    required void Function(String? payload) onTap,
  }) async {
    // TODO: 通知プラグインを初期化
  }
  // 通知を出してよいか、Android/iOSに確認
  Future<void> requestPermissions() async {
    // TODO: 通知を出してよいか、Android/iOSに確認
  }
  // 毎日20時通知を予約
  Future<void> scheduleDailyReviewReminder() async {
    // TODO: 毎日20時通知を予約
  }
  // 毎日20時通知をキャンセル
  Future<void> cancelDailyReviewReminder() async {
    // TODO: 毎日20時通知をキャンセル
  }
}
