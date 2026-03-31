import 'package:serverpod/serverpod.dart';

/// Serverpodの実行モードなどをテンプレートへ流し込むウィジェット。
class BuiltWithServerpodPageWidget extends TemplateWidget {
  BuiltWithServerpodPageWidget() : super(name: 'built_with_serverpod') {
    // テンプレート側で参照する値をここで埋める。
    values = {'served': DateTime.now(), 'runmode': Serverpod.instance.runMode};
  }
}
