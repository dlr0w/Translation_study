import 'package:translation_study_app_server/src/web/widgets/built_with_serverpod_page.dart';
import 'package:serverpod/serverpod.dart';

// `/`へアクセスされたときに返すトップページ。
class RootRoute extends WidgetRoute {
  @override
  Future<TemplateWidget> build(Session session, Request request) async {
    // 静的な紹介ページを返す。
    return BuiltWithServerpodPageWidget();
  }
}
