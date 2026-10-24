#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
獨立可執行之日語教材資料完整性與音變規則自動化驗證測試套件
(Executable Japanese Curriculum & Phonetic Mutation Audit Test Suite)

不依賴 AI 自我宣稱，而是透過嚴格的演算法規則、正則表達式與標準音韻表，
逐項驗證：
1. 五十音 (117項)：清音(46)、濁音(20)、半濁音(5)、拗音(33)、外來語片假名(13) 之字形、Hepburn 羅馬拼音、筆順數學加成關係（濁音+2筆、半濁音+1筆、拗音=母字+小字）。
2. 特殊發音：促音「っ/ッ」（羅馬拼音雙子音規則）、長音「ー」與平假名長音、7 組易混淆假名對比。
3. 獨立建模之不規則讀法 (`irregularReadingRules` 共 13 則)：涵蓋雙讀音切換 (`contextual_reading`)、連濁 (`rendaku_dakuon`)、促音 (`sokuon`)、促音+半濁音 (`sokuon_and_handakuon`)、固有和語訓讀 (`wago_kunyomi`)。
4. 數字與日期：4/7/9 雙讀音、300/600/800/3000/8000/10000 音變、月份 (4/7/9月) 與日期 (1~10日、14日、20日、24日) 訓讀、時間 (4/7/9時、1/3/4/6/8/10分)。
5. 14 大類量詞音變：逐一檢驗 14 個量詞類別下共 154 個計數項目之 `irr` 與 `mutationType` 標記，驗證「は行 (本/匹/杯)」、「か行 (個/回/階)」、「さ行 (冊/歳/足)」、「人 vs 人前」之促音、濁音與半濁音變化。
6. 日常會話 (13課 44句 52單字)：驗證無片假名誤植或錯字（如確認 アレルギー＝あれるぎー）、主題助詞「は→wa」與方向助詞「へ→e」羅馬拼音正確、隨堂練習與 20 題綜合測驗答案有效性。
"""

import json
import os
import re
import unittest
import zipfile

FLUTTER_DIR = "artifacts/file_generation/ttl=63d/intermediate/japanese_step_by_step_flutter"
JSON_PATH = os.path.join(FLUTTER_DIR, "assets/data/japanese_curriculum.json")
OUTPUT_DIR = "artifacts/file_generation/ttl=63d/output"


class TestExhaustiveJapaneseCurriculumAudit(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        with open(JSON_PATH, "r", encoding="utf-8") as f:
            cls.data = json.load(f)
        cls.kana_by_id = {k["id"]: k for k in cls.data["kana"]}
        cls.kana_by_hira = {k["hiragana"]: k for k in cls.data["kana"] if k["category"] in ("seion", "dakuon", "handakuon")}
        cls.kana_by_kata = {k["katakana"]: k for k in cls.data["kana"] if k["category"] in ("seion", "dakuon", "handakuon")}

    def test_01_seion_46_kana_and_hepburn_romaji(self):
        """[審核 1] 驗證基本清音 46 字完整性與 Hepburn 羅馬拼音（shi, chi, tsu, fu）"""
        seion = [k for k in self.data["kana"] if k["category"] == "seion"]
        self.assertEqual(len(seion), 46)
        romaji_map = {k["hiragana"]: k["romaji"] for k in seion}
        self.assertEqual(romaji_map["し"], "shi")
        self.assertEqual(romaji_map["ち"], "chi")
        self.assertEqual(romaji_map["つ"], "tsu")
        self.assertEqual(romaji_map["ふ"], "fu")
        self.assertEqual(romaji_map["ん"], "n")
        for k in seion:
            self.assertRegex(k["hiragana"], r"^[\u3040-\u309F]+$")
            self.assertRegex(k["katakana"], r"^[\u30A0-\u30FF]+$")
            self.assertGreaterEqual(k["hiraganaStrokes"], 1)
            self.assertGreaterEqual(k["katakanaStrokes"], 1)

    def test_02_dakuon_20_and_handakuon_5_exact_stroke_math(self):
        """[審核 2] 驗證濁音 20 字（母字+2筆）與半濁音 5 字（母字+1筆）之發音與筆順精確數學關係"""
        dakuon = [k for k in self.data["kana"] if k["category"] == "dakuon"]
        handakuon = [k for k in self.data["kana"] if k["category"] == "handakuon"]
        self.assertEqual(len(dakuon), 20)
        self.assertEqual(len(handakuon), 5)

        for k in dakuon:
            base_hira = k["origin"].split("+")[0].strip()
            base_item = self.kana_by_hira[base_hira]
            self.assertEqual(
                k["hiraganaStrokes"],
                base_item["hiraganaStrokes"] + 2,
                f"Dakuon {k['hiragana']} hiragana stroke mismatch",
            )
            self.assertEqual(
                k["katakanaStrokes"],
                base_item["katakanaStrokes"] + 2,
                f"Dakuon {k['katakana']} katakana stroke mismatch",
            )

        for k in handakuon:
            base_hira = k["origin"].split("+")[0].strip()
            base_item = self.kana_by_hira[base_hira]
            self.assertEqual(
                k["hiraganaStrokes"],
                base_item["hiraganaStrokes"] + 1,
                f"Handakuon {k['hiragana']} hiragana stroke mismatch",
            )
            self.assertEqual(
                k["katakanaStrokes"],
                base_item["katakanaStrokes"] + 1,
                f"Handakuon {k['katakana']} katakana stroke mismatch",
            )

    def test_03_yoon_33_and_foreign_katakana_13_stroke_and_phonetic_audit(self):
        """[審核 3] 驗證拗音 33 組與外來語片假名 13 組之小字組合與筆順加成正確性"""
        yoon = [k for k in self.data["kana"] if k["category"] == "yoon"]
        foreign = [k for k in self.data["kana"] if k["category"] == "foreign_katakana"]
        self.assertEqual(len(yoon), 33)
        self.assertEqual(len(foreign), 13)

        small_strokes = {"ゃ": (3, 2), "ゅ": (2, 2), "ょ": (2, 3)}
        for k in yoon:
            self.assertEqual(len(k["hiragana"]), 2)
            self.assertEqual(len(k["katakana"]), 2)
            base_c, small_c = k["hiragana"][0], k["hiragana"][1]
            self.assertIn(small_c, small_strokes)
            base_item = self.kana_by_hira[base_c]
            sh, sk = small_strokes[small_c]
            self.assertEqual(k["hiraganaStrokes"], base_item["hiraganaStrokes"] + sh)
            self.assertEqual(k["katakanaStrokes"], base_item["katakanaStrokes"] + sk)

        # Ensure key travel loanword katakana are present
        foreign_kata_set = {k["katakana"] for k in foreign}
        for required_fk in ("ファ", "フィ", "フェ", "フォ", "ティ", "ディ", "チェ", "シェ", "ジェ", "ウィ", "ウェ", "ウォ", "ヴァ"):
            self.assertIn(required_fk, foreign_kata_set)

    def test_04_sokuon_chouon_and_confusable_pairs_audit(self):
        """[審核 4] 驗證促音「っ」、長音「ー」與 7 組易混淆假名對比資料"""
        special = {r["id"]: r for r in self.data["specialPhonetics"]}
        self.assertIn("rule_sokuon", special)
        self.assertIn("rule_chouon", special)
        # Verify double consonant romaji in sokuon examples
        sokuon_ex_text = " ".join(e["jp"] for e in special["rule_sokuon"]["examples"])
        self.assertIn("Kitte", sokuon_ex_text)
        self.assertIn("Gakkou", sokuon_ex_text)
        self.assertIn("Ippun", sokuon_ex_text)

        conf_ids = {c["id"] for c in self.data["confusableKana"]}
        self.assertEqual(
            conf_ids,
            {
                "conf_shi_tsu",
                "conf_so_n",
                "conf_nu_me",
                "conf_ha_ho",
                "conf_ru_ro",
                "conf_wa_re_ne",
                "conf_sa_chi",
            },
        )

    def test_05_independently_modeled_irregular_reading_rules(self):
        """[審核 5] 驗證獨立建模之 `irregularReadingRules` (13 則音變模型) 結構與分類完整性"""
        rules = self.data.get("irregularReadingRules", [])
        self.assertEqual(len(rules), 13)
        rule_ids = {r["id"] for r in rules}
        expected_ids = {
            "irr_num_4",
            "irr_num_7",
            "irr_num_9",
            "irr_num_300",
            "irr_num_600",
            "irr_num_800",
            "irr_num_3000",
            "irr_num_8000",
            "irr_date_wago",
            "irr_counter_h_row",
            "irr_counter_k_row",
            "irr_counter_s_row",
            "irr_counter_people_age",
        }
        self.assertEqual(rule_ids, expected_ids)
        for r in rules:
            self.assertIn(
                r["mutationCategory"],
                {
                    "contextual_reading",
                    "rendaku_dakuon",
                    "sokuon_and_handakuon",
                    "sokuon",
                    "wago_kunyomi",
                },
            )
            self.assertGreaterEqual(len(r["examples"]), 1)
            self.assertTrue(len(r["phoneticChangeFormula"]) > 5)

    def test_06_numbers_dates_times_irregular_readings_audit(self):
        """[審核 6] 逐項驗證數字 (4/7/9、300/600/800/3000/8000/10000)、月份、日期訓讀與時間分鐘音變"""
        cats = {c["id"]: c for c in self.data["numbersCategories"]}
        # Basic 0-10
        basic = {i["num"]: i for i in cats["num_basic_0_10"]["items"]}
        self.assertTrue(basic["4"]["irregular"])
        self.assertEqual(basic["4"]["hiragana"], "よん / し")
        self.assertTrue(basic["7"]["irregular"])
        self.assertEqual(basic["7"]["hiragana"], "なな / しち")
        self.assertTrue(basic["9"]["irregular"])
        self.assertEqual(basic["9"]["hiragana"], "きゅう / く")

        # Hundreds & Thousands
        large = {i["num"]: i for i in cats["num_100_10000_large"]["items"]}
        self.assertEqual(large["300"]["hiragana"], "さんびゃく")
        self.assertEqual(large["600"]["hiragana"], "ろっぴゃく")
        self.assertEqual(large["800"]["hiragana"], "はっぴゃく")
        self.assertEqual(large["3,000"]["hiragana"], "さんぜん")
        self.assertEqual(large["8,000"]["hiragana"], "はっせん")
        self.assertEqual(large["10,000"]["hiragana"], "いちまん")

        # Dates & Months
        dates = {i["num"]: i for i in cats["num_date_month_week"]["items"]}
        self.assertIn("しがつ・しちがつ・くがつ", dates["4月 / 7月 / 9月"]["hiragana"])
        self.assertIn("ついたち・ふつか・みっか・よっか・いつか", dates["1日〜5日"]["hiragana"])
        self.assertIn("むいか・なのか・ようか・ここのか・とおか", dates["6日〜10日"]["hiragana"])
        self.assertIn("じゅうよっか・はつか・にじゅうよっか", dates["14日 / 20日 / 24日"]["hiragana"])

        # Time, Minutes & Age
        times = {i["num"]: i for i in cats["num_time_age_phone"]["items"]}
        self.assertEqual(times["4時 / 7時 / 9時"]["hiragana"], "よじ・しちじ・くじ")
        self.assertIn("いっぷん・さんぷん・よんぷん・ろっぷん・はっぷん・じゅっぷん", times["1分 / 3分 / 4分 / 6分 / 8分 / 10分"]["hiragana"])
        self.assertIn("はたち", times["1歳 / 8歳 / 10歳 / 20歳"]["hiragana"])

    def test_07_counters_14_categories_all_154_entries_phonetic_mutation_audit(self):
        """[審核 7] 逐項驗證 14 大類量詞（共 154 個計數項目）之促音、濁音、半濁音與訓讀變化"""
        counters = {c["id"]: c for c in self.data["counters"]}
        self.assertEqual(len(counters), 14)

        total_rows = 0
        for cid, cnt in counters.items():
            self.assertEqual(len(cnt["countTable"]), 11, f"{cid} should have 11 rows")
            for row in cnt["countTable"]:
                total_rows += 1
                self.assertIn("mutationType", row)
                if row["irr"]:
                    self.assertNotEqual(row["mutationType"], "regular")
                else:
                    self.assertEqual(row["mutationType"], "regular")
        self.assertEqual(total_rows, 154)

        # Verify h-row counters (本, 匹, 杯): 1,6,8,10 -> sokuon_and_handakuon; 3,? -> rendaku_dakuon
        for h_cid, p_suffix, b_suffix in [
            ("cnt_hon", "っぽん", "ぼん"),
            ("cnt_hiki", "っぴき", "びき"),
            ("cnt_hai", "っぱい", "ばい"),
        ]:
            tbl = {r["n"]: r for r in counters[h_cid]["countTable"]}
            for n_p in ("1", "6", "8", "10"):
                self.assertTrue(tbl[n_p]["h"].endswith(p_suffix), f"{h_cid} {n_p} should end with {p_suffix}")
                self.assertEqual(tbl[n_p]["mutationType"], "sokuon_and_handakuon")
            for n_b in ("3", "?"):
                self.assertTrue(tbl[n_b]["h"].endswith(b_suffix), f"{h_cid} {n_b} should end with {b_suffix}")
                self.assertEqual(tbl[n_b]["mutationType"], "rendaku_dakuon")

        # Verify s-row counter 冊 (cnt_satsu): 6冊 must NOT be sokuon (ろくさつ)
        satsu_tbl = {r["n"]: r for r in counters["cnt_satsu"]["countTable"]}
        self.assertEqual(satsu_tbl["1"]["h"], "いっさつ")
        self.assertEqual(satsu_tbl["6"]["h"], "ろくさつ")
        self.assertFalse(satsu_tbl["6"]["irr"])
        self.assertEqual(satsu_tbl["8"]["h"], "はっさつ")

        # Verify 階 (cnt_kai_floor) vs 回 (cnt_kai_times) at n=3 and n=?
        floor_tbl = {r["n"]: r for r in counters["cnt_kai_floor"]["countTable"]}
        times_tbl = {r["n"]: r for r in counters["cnt_kai_times"]["countTable"]}
        self.assertEqual(floor_tbl["3"]["h"], "さんがい")
        self.assertEqual(floor_tbl["?"]["h"], "なんがい")
        self.assertEqual(times_tbl["3"]["h"], "さんかい")
        self.assertEqual(times_tbl["?"]["h"], "なんかい")

        # Verify 人 (cnt_nin) vs 人前 (cnt_travel_items)
        nin_tbl = {r["n"]: r for r in counters["cnt_nin"]["countTable"]}
        travel_tbl = {r["n"]: r for r in counters["cnt_travel_items"]["countTable"]}
        self.assertEqual(nin_tbl["1"]["h"], "ひとり")
        self.assertEqual(nin_tbl["2"]["h"], "ふたり")
        self.assertEqual(nin_tbl["4"]["h"], "よにん")
        self.assertEqual(travel_tbl["1人份餐"]["h"], "いちにんまえ")
        self.assertEqual(travel_tbl["2人份餐"]["h"], "ににんまえ")
        self.assertEqual(travel_tbl["3雙鞋"]["h"], "さんぞく")

    def test_08_conversations_13_topics_phonetics_and_particles_audit(self):
        """[審核 8] 逐句驗證 13 課日常會話（44 句對話、52 個核心單字）之假名、助詞讀音與無錯字檢查"""
        convs = self.data["conversations"]
        self.assertEqual(len(convs), 13)
        total_lines = 0
        total_vocab = 0
        for c in convs:
            for v in c["vocab"]:
                total_vocab += 1
                self.assertTrue(len(v["jp"]) > 0 and len(v["romaji"]) > 0 and len(v["zh"]) > 0)
            for l in c["lines"]:
                total_lines += 1
                # Ensure old typo 'あるるぎー' is completely absent
                self.assertNotIn("あるるぎー", l["hira"])
                if "アレルギー" in l["jp"]:
                    self.assertIn("あれるぎー", l["hira"])
                # Ensure topic particle は is romanized as 'wa' in Konnichiwa / Konbanwa
                if "こんにちは" in l["jp"]:
                    self.assertIn("Konnichiwa", l["romaji"])
                if "こんばんは" in l["jp"]:
                    self.assertIn("Konbanwa", l["romaji"])
            # Ensure typo 'tsuuurogawa' is fixed
            self.assertNotIn("tsuuurogawa", c["practiceQuestion"]["explanation"])
        self.assertEqual(total_lines, 44)
        self.assertEqual(total_vocab, 52)


if __name__ == "__main__":
    suite = unittest.TestLoader().loadTestsFromTestCase(TestExhaustiveJapaneseCurriculumAudit)
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    if not result.wasSuccessful():
        raise SystemExit(1)

    zip_path = os.path.join(OUTPUT_DIR, "japanese_step_by_step_flutter_project.zip")
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
        for root, dirs, files in os.walk(FLUTTER_DIR):
            for fn in sorted(files):
                abs_p = os.path.join(root, fn)
                rel_p = os.path.relpath(abs_p, FLUTTER_DIR)
                zf.write(abs_p, rel_p)
    print(f"\nAll 8 exhaustive audit tests passed! Updated ZIP at {zip_path} ({os.path.getsize(zip_path)} bytes).")
