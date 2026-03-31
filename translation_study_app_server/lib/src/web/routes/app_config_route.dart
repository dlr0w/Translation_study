import 'package:serverpod/serverpod.dart';

// Flutter Webが読むJSON。
class AppConfigWidget extends JsonWidget {
  // APIサーバーのURL。
  final String apiUrl;

  AppConfigWidget({
    required this.apiUrl,
  }) : super(object: {'apiUrl': apiUrl});
}

// JSONを返すルート。
class AppConfigRoute extends WidgetRoute {
  // 同じJSONを返すだけなのでwidgetを保持して使い回す。
  AppConfigWidget widget;

  AppConfigRoute({
    required final ServerConfig apiConfig,
  }) : widget = AppConfigWidget(apiUrl: apiConfig.apiUrl.toString());

  @override
  Future<WebWidget> build(Session session, Request request) async {
    // リクエストごとの分岐は無いのでそのまま返す。
    return widget;
  }
}

// Serverpodの公開設定からAPI URLを組み立てる。
extension on ServerConfig {
  Uri get apiUrl => Uri(
    scheme: publicScheme,
    host: publicHost,
    port: publicPort,
  );
}
