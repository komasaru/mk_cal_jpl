require "spec_helper"

describe MkCalJpl::Const do
  context "USAGE" do
    it do
      expect(MkCalJpl::Const::USAGE).to \
      eq %Q{[USAGE] `MkCalJpl.new("<JPL_BIN_PATH>"[, "YYYYMMDD"])`}
    end
  end

  context "MSG_ERR_1" do
    it do
      expect(MkCalJpl::Const::MSG_ERR_1).to \
      eq "[ERROR] Binary file could not be found!"
    end
  end

  context "MSG_ERR_2" do
    it do
      expect(MkCalJpl::Const::MSG_ERR_2).to \
      eq "[ERROR] Date format should be `YYYYMMDD`!"
    end
  end

  context "MSG_ERR_3" do
    it do
      expect(MkCalJpl::Const::MSG_ERR_3).to \
      eq "[ERROR] Date is invalid!"
    end
  end

  context "JST_D" do
    it { expect(MkCalJpl::Const::JST_D).to eq 0.375 }
  end

  context "TT_TAI" do
    it { expect(MkCalJpl::Const::TT_TAI).to eq 32.184 }
  end

  context "YOBI" do
    it do
      expect(MkCalJpl::Const::YOBI).to \
      match(["日", "月", "火", "水", "木", "金", "土"])
    end
  end

  context "ROKUYO" do
    it do
      expect(MkCalJpl::Const::ROKUYO).to \
      match(["大安", "赤口", "先勝", "友引", "先負", "仏滅"])
    end
  end

  context "KANSHI" do
    it do
      expect(MkCalJpl::Const::KANSHI).to \
      match([
        "甲子", "乙丑", "丙寅", "丁卯", "戊辰", "己巳", "庚午", "辛未", "壬申", "癸酉",
        "甲戌", "乙亥", "丙子", "丁丑", "戊寅", "己卯", "庚辰", "辛巳", "壬午", "癸未",
        "甲申", "乙酉", "丙戌", "丁亥", "戊子", "己丑", "庚寅", "辛卯", "壬辰", "癸巳",
        "甲午", "乙未", "丙申", "丁酉", "戊戌", "己亥", "庚子", "辛丑", "壬寅", "癸卯",
        "甲辰", "乙巳", "丙午", "丁未", "戊申", "己酉", "庚戌", "辛亥", "壬子", "癸丑",
        "甲寅", "乙卯", "丙辰", "丁巳", "戊午", "己未", "庚申", "辛酉", "壬戌", "癸亥"
      ])
    end
  end

  context "SEKKI_24" do
    it do
      expect(MkCalJpl::Const::SEKKI_24).to \
      match([
        "春分", "清明", "穀雨", "立夏", "小満", "芒種",
        "夏至", "小暑", "大暑", "立秋", "処暑", "白露",
        "秋分", "寒露", "霜降", "立冬", "小雪", "大雪",
        "冬至", "小寒", "大寒", "立春", "雨水", "啓蟄"
      ])
    end
  end

  context "SEKKU" do
    it do
      expect(MkCalJpl::Const::SEKKU).to \
      match([
        [0, 1, 7, "人日"],
        [1, 3, 3, "上巳"],
        [2, 5, 5, "端午"],
        [3, 7, 7, "七夕"],
        [4, 9, 9, "重陽"]
      ])
    end
  end

  context "ZASSETSU" do
    it do
      expect(MkCalJpl::Const::ZASSETSU).to \
      match([
        "節分"      , "彼岸入(春)", "彼岸(春)"  , "彼岸明(春)",
        "社日(春)"  , "土用入(春)", "八十八夜"  , "入梅"      ,
        "半夏生"    , "土用入(夏)", "二百十日"  , "二百二十日",
        "彼岸入(秋)", "彼岸(秋)"  , "彼岸明(秋)", "社日(秋)"  ,
        "土用入(秋)", "土用入(冬)"
      ])
    end
  end

  context "HOLIDAY" do
    it do
      expect(MkCalJpl::Const::HOLIDAY).to \
      match([
        [ 0,  1,  1, 0, "元日"        ],
        [ 1,  1,  0, 2, "成人の日"    ],
        [ 2,  2, 11, 0, "建国記念の日"],
        [ 3,  3,  0, 4, "春分の日"    ],
        [ 4,  4, 29, 0, "昭和の日"    ],
        [ 5,  5,  3, 0, "憲法記念日"  ],
        [ 6,  5,  4, 0, "みどりの日"  ],
        [ 7,  5,  5, 0, "こどもの日"  ],
        [ 8,  7,  0, 3, "海の日"      ],
        [ 9,  8, 11, 0, "山の日"      ],
        [10,  9,  0, 3, "敬老の日"    ],
        [11,  9,  0, 4, "秋分の日"    ],
        [12, 10,  0, 2, "体育の日"    ],
        [13, 11,  3, 0, "文化の日"    ],
        [14, 11, 23, 0, "勤労感謝の日"],
        [15, 12, 23, 0, "天皇誕生日"  ],
        [90,  0,  0, 8, "国民の休日"  ],
        [91,  0,  0, 9, "振替休日"    ]
      ])
    end
  end

  context "SEKKI_24_TM" do
    it do
      expect(MkCalJpl::Const::SEKKI_24_TM[0, 5 * 7]).to \
      match([
        "1899", "1",  "5", "21", "16", "50", "285",
        "1899", "1", "20", "14", "37",  "3", "300",
        "1899", "2",  "4",  "9",  "6", "19", "315",
        "1899", "2", "19",  "5",  "7", "15", "330",
        "1899", "3",  "6",  "3", "37", "34", "345"
      ])
    end
    it do
      expect(MkCalJpl::Const::SEKKI_24_TM[-5 * 7, 5 * 7]).to \
      match([
        "2099", "10", "23", "11", "15", "27", "210",
        "2099", "11",  "7", "11", "45", "11", "225",
        "2099", "11", "22",  "9", "25",  "9", "240",
        "2099", "12",  "7",  "5",  "5", "49", "255",
        "2099", "12", "21", "23",  "6", "52", "270",
      ])
    end
  end

  context "SAKU_TM" do
    it do
      expect(MkCalJpl::Const::SAKU_TM[0, 5 * 6]).to \
      match([
        "1899", "1", "12",  "7", "48", "41",
        "1899", "2", "10", "18", "30", "52",
        "1899", "3", "12",  "4", "51", "52",
        "1899", "4", "10", "15", "19", "51",
        "1899", "5", "10",  "2", "37", "42",
      ])
    end
    it do
      expect(MkCalJpl::Const::SAKU_TM[-5 * 6, 5 * 6]).to \
      match([
        "2099",  "8", "16", "17", "56", "58",
        "2099",  "9", "15",  "1", "53",  "8",
        "2099", "10", "14", "10", "34", "44",
        "2099", "11", "12", "20", "31", "50",
        "2099", "12", "12",  "8", "11", "21",
      ])
    end
  end
end

