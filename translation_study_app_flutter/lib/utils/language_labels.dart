// 画面表示に使う言語名の対応表。
const languageLabels = <String, String>{
  'ja': '日本語',
  'en': '英語',
  'es': 'スペイン語',
  'fr': 'フランス語',
  'de': 'ドイツ語',
  'ko': '韓国語',
  'zh-cn': '中国語 (簡体字)',
};

// 未対応コードでもそのまま表示できるようにする。
String languageLabelOf(String code) {
  // 対応表に無ければ入力値をそのまま返す。
  return languageLabels[code] ?? code;
}
