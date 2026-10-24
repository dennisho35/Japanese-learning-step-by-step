/// 日語數字與金額音變轉換服務（支援 0 〜 99,999,999，含 300/600/800/3000/8000 音變）
class JapaneseNumberResult {
  final String kanji;
  final String hiragana;
  final String romaji;

  const JapaneseNumberResult({
    required this.kanji,
    required this.hiragana,
    required this.romaji,
  });
}

class NumberConverterService {
  static const List<String> _onesK = ['', '一', '二', '三', '四', '五', '六', '七', '八', '九'];
  static const List<String> _onesH = ['', 'いち', 'に', 'さん', 'よん', 'ご', 'ろく', 'なな', 'はち', 'きゅう'];
  static const List<String> _onesR = ['', 'ichi', 'ni', 'san', 'yon', 'go', 'roku', 'nana', 'hachi', 'kyuu'];

  static JapaneseNumberResult convert(int n) {
    if (n <= 0) {
      return const JapaneseNumberResult(
        kanji: '零 / ゼロ',
        hiragana: 'ゼロ (れい)',
        romaji: 'zero (rei)',
      );
    }

    JapaneseNumberResult under10000(int val) {
      String k = '';
      String h = '';
      String r = '';
      final sen = val ~/ 1000;
      final hyaku = (val % 1000) ~/ 100;
      final juu = (val % 100) ~/ 10;
      final ichi = val % 10;

      if (sen > 0) {
        if (sen == 1) {
          k += '千';
          h += 'せん';
          r += 'sen ';
        } else if (sen == 3) {
          k += '三千';
          h += 'さんぜん';
          r += 'sanzen ';
        } else if (sen == 8) {
          k += '八千';
          h += 'はっせん';
          r += 'hassen ';
        } else {
          k += '${_onesK[sen]}千';
          h += '${_onesH[sen]}せん';
          r += '${_onesR[sen]}sen ';
        }
      }
      if (hyaku > 0) {
        if (hyaku == 1) {
          k += '百';
          h += 'ひゃく';
          r += 'hyaku ';
        } else if (hyaku == 3) {
          k += '三百';
          h += 'さんびゃく';
          r += 'sanbyaku ';
        } else if (hyaku == 6) {
          k += '六百';
          h += 'ろっぴゃく';
          r += 'roppyaku ';
        } else if (hyaku == 8) {
          k += '八百';
          h += 'はっぴゃく';
          r += 'happyaku ';
        } else {
          k += '${_onesK[hyaku]}百';
          h += '${_onesH[hyaku]}ひゃく';
          r += '${_onesR[hyaku]}hyaku ';
        }
      }
      if (juu > 0) {
        if (juu == 1) {
          k += '十';
          h += 'じゅう';
          r += 'juu ';
        } else {
          k += '${_onesK[juu]}十';
          h += '${_onesH[juu]}じゅう';
          r += '${_onesR[juu]}juu ';
        }
      }
      if (ichi > 0) {
        k += _onesK[ichi];
        h += _onesH[ichi];
        r += _onesR[ichi];
      }
      return JapaneseNumberResult(kanji: k, hiragana: h, romaji: r.trim());
    }

    final man = n ~/ 10000;
    final rem = n % 10000;
    String kanji = '';
    String hira = '';
    String romaji = '';

    if (man > 0) {
      final mPart = under10000(man);
      kanji += '${mPart.kanji}万';
      hira += '${mPart.hiragana}まん ';
      romaji += '${mPart.romaji}-man ';
    }
    if (rem > 0) {
      final rPart = under10000(rem);
      kanji += rPart.kanji;
      hira += rPart.hiragana;
      romaji += rPart.romaji;
    }

    return JapaneseNumberResult(
      kanji: kanji,
      hiragana: hira.trim(),
      romaji: romaji.trim(),
    );
  }
}
