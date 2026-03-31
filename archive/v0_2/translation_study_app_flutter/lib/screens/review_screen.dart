// ランダム出題のため乱数機能を利用する。
import 'dart:math';

// FlutterのMaterial UI部品を利用する。
import 'package:flutter/material.dart';

// 復習結果モデルを利用する。
import '../models/review_result_entry.dart';
// 集計表示モデルを利用する。
import '../models/review_summary.dart';
// 翻訳履歴モデルを利用する。
import '../models/translation_history_entry.dart';
// ローカルDB操作を行うリポジトリを利用する。
import '../repositories/local_history_repository.dart';

// v0.2の復習画面本体。
class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  // 状態管理クラスを生成する。
  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

// 復習画面の状態を保持するクラス。
class _ReviewScreenState extends State<ReviewScreen> {
  // 回答入力欄の内容を管理する。
  final _answerController = TextEditingController();
  // ランダム出題に使う乱数生成器を保持する。
  final _random = Random();

  // 復習対象となる翻訳履歴一覧を保持する。
  List<TranslationHistoryEntry> _histories = const [];
  // 現在出題中の問題を保持する。
  TranslationHistoryEntry? _currentQuestion;
  // 復習の基本集計を保持する。
  ReviewSummary _summary = const ReviewSummary(
    // 初期状態の翻訳件数は0。
    translationCount: 0,
    // 初期状態の復習件数は0。
    reviewCount: 0,
    // 初期状態の正解件数は0。
    correctCount: 0,
    // 初期状態の部分正解件数は0。
    partialCount: 0,
    // 初期状態の不正解件数は0。
    incorrectCount: 0,
  );

  // 初期データ読み込み中かどうかを保持する。
  bool _isLoading = true;
  // 模範解答を表示中かどうかを保持する。
  bool _isAnswerShown = false;
  // 採点結果を保存中かどうかを保持する。
  bool _isSavingResult = false;

  // 画面生成時の初期化処理。
  @override
  void initState() {
    // 親クラスの初期化を実行する。
    super.initState();
    // 復習画面で必要なデータを読み込む。
    _loadData();
  }

  // 復習画面に必要なデータを読み込む。
  Future<void> _loadData() async {
    // 読み込み開始をUIに反映する。
    setState(() {
      // ローディング表示を有効化する。
      _isLoading = true;
    });

    // 保存済み翻訳履歴を取得する。
    final histories = await LocalHistoryRepository.instance.all();
    // 保存済み復習結果の集計を取得する。
    final summary = await LocalHistoryRepository.instance.getReviewSummary();

    // 画面が破棄済みなら更新せず終了する。
    if (!mounted) return;

    // 取得したデータを画面状態へ反映する。
    setState(() {
      // 履歴一覧を更新する。
      _histories = histories;
      // 集計値を更新する。
      _summary = summary;
      // 履歴があればランダムで1問選ぶ。
      _currentQuestion = histories.isEmpty ? null : _pickRandomQuestion(histories);
      // 模範解答表示をリセットする。
      _isAnswerShown = false;
      // 回答入力欄を空にする。
      _answerController.clear();
      // ローディング表示を終了する。
      _isLoading = false;
    });
  }

  // 履歴一覧からランダムに1問選ぶ。
  TranslationHistoryEntry _pickRandomQuestion(List<TranslationHistoryEntry> histories) {
    // 履歴件数を上限にランダムインデックスを作る。
    final index = _random.nextInt(histories.length);
    // ランダムに選んだ履歴を返す。
    return histories[index];
  }

  // 模範解答を表示状態にする。
  void _showAnswer() {
    // 状態変更をUIへ反映する。
    setState(() {
      // 模範解答を表示する。
      _isAnswerShown = true;
    });
  }

  // 自己採点を保存し、次の問題へ進める。
  Future<void> _saveResultAndNext(ReviewGrade grade) async {
    // 出題または履歴IDが無い場合は保存できないため終了する。
    if (_currentQuestion == null || _currentQuestion!.id == null) {
      return;
    }
    // 保存中の二重実行を防ぐ。
    if (_isSavingResult) return;

    // 保存開始をUIへ反映する。
    setState(() {
      // 保存中フラグを有効化する。
      _isSavingResult = true;
    });

    // 保存対象の復習結果モデルを作成する。
    final entry = ReviewResultEntry(
      // 出題元の翻訳履歴IDを設定する。
      historyId: _currentQuestion!.id!,
      // 入力回答を前後空白除去して設定する。
      answerText: _answerController.text.trim(),
      // 選択された採点を設定する。
      grade: grade,
      // 保存時刻を現在時刻で設定する。
      reviewedAt: DateTime.now(),
    );

    // 復習結果をローカルDBへ保存する。
    await LocalHistoryRepository.instance.addReviewResult(entry);
    // 保存後の最新集計を再取得する。
    final summary = await LocalHistoryRepository.instance.getReviewSummary();

    // 画面が破棄済みなら更新せず終了する。
    if (!mounted) return;

    // 保存結果と次の問題を画面へ反映する。
    setState(() {
      // 集計表示を最新化する。
      _summary = summary;
      // 次の問題をランダムで選び直す。
      _currentQuestion = _histories.isEmpty ? null : _pickRandomQuestion(_histories);
      // 回答入力をリセットする。
      _answerController.clear();
      // 模範解答表示をリセットする。
      _isAnswerShown = false;
      // 保存中フラグを無効化する。
      _isSavingResult = false;
    });
  }

  // 画面UIを構築する。
  @override
  Widget build(BuildContext context) {
    // 読み込み中ならローディング画面を返す。
    if (_isLoading) {
      return Scaffold(
        // 復習画面タイトルを表示する。
        appBar: AppBar(title: const Text('復習')),
        // 進行中インジケーターを中央表示する。
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 履歴が無い場合は案内画面を返す。
    if (_histories.isEmpty) {
      return Scaffold(
        // 復習画面タイトルを表示する。
        appBar: AppBar(title: const Text('復習')),
        // 翻訳が先に必要であることを表示する。
        body: const Center(child: Text('翻訳履歴がありません。先に翻訳を実行してください。')),
      );
    }

    // 現在の出題を非nullとして参照する。
    final question = _currentQuestion!;

    // 復習画面本体を返す。
    return Scaffold(
      // 上部バーを構築する。
      appBar: AppBar(
        // 画面タイトルを表示する。
        title: const Text('復習'),
        // 右上アクションを表示する。
        actions: [
          // 再読み込みボタンを表示する。
          IconButton(
            // タップ時にデータを再読み込みする。
            onPressed: _loadData,
            // 更新アイコンを表示する。
            icon: const Icon(Icons.refresh),
            // ツールチップを表示する。
            tooltip: '再読み込み',
          ),
        ],
      ),
      // 本文領域を構築する。
      body: Padding(
        // 全方向に余白を入れる。
        padding: const EdgeInsets.all(16),
        // 子要素を縦に並べる。
        child: Column(
          // 子要素を横幅いっぱいに広げる。
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // 画面の要素一覧を定義する。
          children: [
            // 集計カードを表示する。
            _SummaryCard(summary: _summary),
            // 集計カード下の余白を入れる。
            const SizedBox(height: 16),
            // 問題見出しを表示する。
            const Text('問題（原文）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            // 見出しと問題文の間に余白を入れる。
            const SizedBox(height: 8),
            // 問題文表示用コンテナを表示する。
            Container(
              // 問題文の内側余白を設定する。
              padding: const EdgeInsets.all(12),
              // 枠線と角丸を設定する。
              decoration: BoxDecoration(
                // グレーの枠線を表示する。
                border: Border.all(color: Colors.grey.shade400),
                // 角丸を設定する。
                borderRadius: BorderRadius.circular(8),
              ),
              // 原文を問題として表示する。
              child: Text(question.sourceText),
            ),
            // 問題文と言語表示の間に余白を入れる。
            const SizedBox(height: 8),
            // 問題の言語ペアを表示する。
            Text('言語: ${question.sourceLanguage} -> ${question.targetLanguage}'),
            // 言語表示と回答欄の間に余白を入れる。
            const SizedBox(height: 12),
            // 回答入力欄を表示する。
            TextField(
              // 回答入力欄をコントローラーに紐付ける。
              controller: _answerController,
              // 最小表示行数を設定する。
              minLines: 2,
              // 最大表示行数を設定する。
              maxLines: 5,
              // 入力欄の装飾を設定する。
              decoration: const InputDecoration(
                // 外枠を表示する。
                border: OutlineInputBorder(),
                // ラベル文言を表示する。
                labelText: 'あなたの回答（訳文）',
              ),
            ),
            // 回答欄とボタンの間に余白を入れる。
            const SizedBox(height: 12),
            // 模範解答表示ボタンを表示する。
            ElevatedButton(
              // 既に表示済みなら無効化し、未表示なら表示処理を実行する。
              // TODO:表示済みの時にはボタンの押して未表示にする            
              onPressed: _isAnswerShown ? null : _showAnswer,
              // ボタン文言を表示する。
              child: const Text('模範解答を表示'),
            ),
            // ボタン下に余白を入れる。
            const SizedBox(height: 12),
            // 模範解答表示中のみ採点エリアを表示する。
            if (_isAnswerShown) ...[
              // 模範解答表示コンテナを表示する。
              Container(
                // 内側余白を設定する。
                padding: const EdgeInsets.all(12),
                // 背景色と枠線を設定する。
                decoration: BoxDecoration(
                  // 模範解答を目立たせる背景色を設定する。
                  color: Colors.teal.shade50,
                  // 枠線色を設定する。
                  border: Border.all(color: Colors.teal.shade200),
                  // 角丸を設定する。
                  borderRadius: BorderRadius.circular(8),
                ),
                // 模範解答を表示する。
                child: Text('模範解答: ${question.translatedText}'),
              ),
              // 模範解答と採点見出しの間に余白を入れる。
              const SizedBox(height: 12),
              // 自己採点見出しを表示する。
              const Text('自己採点', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              // 見出しと採点ボタンの間に余白を入れる。
              const SizedBox(height: 8),
              // 採点ボタンを横並びで表示する。
              Row(
                // 採点ボタンの一覧を定義する。
                children: [
                  // 正解ボタンの横幅を均等にする。
                  Expanded(
                    // 正解ボタンを表示する。
                    child: ElevatedButton(
                      // 保存中は無効化し、押下時に正解として保存する。
                      onPressed: _isSavingResult ? null : () => _saveResultAndNext(ReviewGrade.correct),
                      // ボタン文言（◯）を表示する。
                      child: const Text('◯'),
                    ),
                  ),
                  // ボタン間に余白を入れる。
                  const SizedBox(width: 8),
                  // 部分正解ボタンの横幅を均等にする。
                  Expanded(
                    // 部分正解ボタンを表示する。
                    child: ElevatedButton(
                      // 保存中は無効化し、押下時に部分正解として保存する。
                      onPressed: _isSavingResult ? null : () => _saveResultAndNext(ReviewGrade.partial),
                      // ボタン文言（△）を表示する。
                      child: const Text('△'),
                    ),
                  ),
                  // ボタン間に余白を入れる。
                  const SizedBox(width: 8),
                  // 不正解ボタンの横幅を均等にする。
                  Expanded(
                    // 不正解ボタンを表示する。
                    child: ElevatedButton(
                      // 保存中は無効化し、押下時に不正解として保存する。
                      onPressed: _isSavingResult ? null : () => _saveResultAndNext(ReviewGrade.incorrect),
                      // ボタン文言（×）を表示する。
                      child: const Text('×'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 復習の基本集計表示カード。
class _SummaryCard extends StatelessWidget {
  // 表示対象の集計データを受け取る。
  const _SummaryCard({required this.summary});

  // 表示対象の集計データ。
  final ReviewSummary summary;

  // 集計カードのUIを構築する。
  @override
  Widget build(BuildContext context) {
    // 正解率をパーセント文字列へ変換する。
    final ratePercent = (summary.correctRate * 100).toStringAsFixed(1);

    // 集計表示カードを返す。
    return Card(
      // カード内に余白を入れる。
      child: Padding(
        // 全方向12pxの余白を設定する。
        padding: const EdgeInsets.all(12),
        // 集計項目を縦に並べる。
        child: Column(
          // 集計項目を左寄せで表示する。
          crossAxisAlignment: CrossAxisAlignment.start,
          // 表示する項目を定義する。
          children: [
            // 集計セクション見出しを表示する。
            const Text('学習統計（基本）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            // 見出し下に余白を入れる。
            const SizedBox(height: 8),
            // 翻訳回数を表示する。
            Text('翻訳回数: ${summary.translationCount}'),
            // 復習回数を表示する。
            Text('復習回数: ${summary.reviewCount}'),
            // 正解率を表示する。
            Text('正解率: $ratePercent%'),
            // 採点内訳を表示する。
            Text('内訳: ◯${summary.correctCount} / △${summary.partialCount} / ×${summary.incorrectCount}'),
          ],
        ),
      ),
    );
  }
}
