// MaterialデザインのUI部品を利用する。
import 'package:flutter/material.dart';

// 復習画面を表示するために読み込む。
import 'review_screen.dart';
// 翻訳画面を表示するために読み込む。
import 'translation_screen.dart';

// v0.2のホーム画面（翻訳/復習タブの切り替え）。
class AppHomeScreen extends StatefulWidget {
  // 親から渡される key を受け取る。
  const AppHomeScreen({super.key});

  // 状態管理クラスを生成する。
  @override
  State<AppHomeScreen> createState() => _AppHomeScreenState();
}

// ホーム画面の表示状態（選択中タブ）を保持するクラス。
class _AppHomeScreenState extends State<AppHomeScreen> {
  // 現在選択中のタブ番号（0=翻訳、1=復習）。
  int _selectedIndex = 0;

  // タブに対応する表示画面を定義する。
  static final List<Widget> _pages = <Widget>[
    // 翻訳タブで表示する画面。
    const TranslationScreen(),
    // 復習タブで表示する画面。
    const ReviewScreen(),
  ];

  // 現在選択中タブに応じたUIを構築する。
  @override
  Widget build(BuildContext context) {
    // 画面全体の土台を作る。
    return Scaffold(
      // 選択中タブの画面を本文に表示する。
      body: _pages[_selectedIndex],
      // 画面下部にタブ切り替えUIを表示する。
      bottomNavigationBar: NavigationBar(
        // 現在選択中のタブを反映する。
        selectedIndex: _selectedIndex,
        // タブ選択時に呼ばれる処理を定義する。
        onDestinationSelected: (index) {
          // 選択中タブを更新して再描画する。
          setState(() {
            // 新しく選択されたタブ番号を保持する。
            _selectedIndex = index;
          });
        },
        // 表示するタブ項目を定義する。
        destinations: const [
          // 翻訳タブの見た目を定義する。
          NavigationDestination(
            // 翻訳タブのアイコンを表示する。
            icon: Icon(Icons.translate),
            // 翻訳タブのラベルを表示する。
            label: '翻訳',
          ),
          // 復習タブの見た目を定義する。
          NavigationDestination(
            // 復習タブのアイコンを表示する。
            icon: Icon(Icons.quiz),
            // 復習タブのラベルを表示する。
            label: '復習',
          ),
        ],
      ),
    );
  }
}
