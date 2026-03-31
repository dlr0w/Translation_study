import 'package:flutter/material.dart';

import '../main.dart';

class GreetingsScreen extends StatefulWidget {
  final Future<void> Function()? onSignOut;
  const GreetingsScreen({super.key, this.onSignOut});

  @override
  State<GreetingsScreen> createState() => _GreetingsScreenState();
}

class _GreetingsScreenState extends State<GreetingsScreen> {
  /// 直近の成功結果。未取得時は null。
  String? _resultMessage;

  /// 直近のエラーメッセージ。エラーが無い時は null。
  String? _errorMessage;

  final _textEditingController = TextEditingController();

  /// `greeting` endpoint の `hello` を呼び出し、結果かエラーを保持する。
  void _callHello() async {
    try {
      final result = await client.greeting.hello(_textEditingController.text);
      setState(() {
        _errorMessage = null;
        _resultMessage = result.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (widget.onSignOut != null) ...[
            const Text('You are connected'),
            ElevatedButton(
              onPressed: widget.onSignOut,
              child: const Text('Sign out'),
            ),
          ],
          const SizedBox(height: 32),
          TextField(
            controller: _textEditingController,
            decoration: const InputDecoration(hintText: 'Enter your name'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _callHello,
            child: const Text('Send to Server'),
          ),
          const SizedBox(height: 16),
          ResultDisplay(
            resultMessage: _resultMessage,
            errorMessage: _errorMessage,
          ),
        ],
      ),
    );
  }
}

/// サーバー呼び出し結果を表示する部品。
class ResultDisplay extends StatelessWidget {
  final String? resultMessage;
  final String? errorMessage;

  const ResultDisplay({super.key, this.resultMessage, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    String text;
    Color backgroundColor;
    if (errorMessage != null) {
      backgroundColor = Colors.red[300]!;
      text = errorMessage!;
    } else if (resultMessage != null) {
      backgroundColor = Colors.green[300]!;
      text = resultMessage!;
    } else {
      backgroundColor = Colors.grey[300]!;
      text = 'No server response yet.';
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 50),
      child: Container(
        color: backgroundColor,
        child: Center(child: Text(text)),
      ),
    );
  }
}
