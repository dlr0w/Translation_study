import 'package:serverpod/serverpod.dart';

// 動作確認用の最小endpoint。
class SystemEndpoint extends Endpoint {
  // サーバーが応答できるかを返す。
  Future<String> health(Session session) async {
    // 応答時刻も含めて返して確認しやすくする。
    return 'ok:${DateTime.now().toUtc().toIso8601String()}';
  }
}
