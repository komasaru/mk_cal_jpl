require 'mk_time'

module MkCalJpl
  module Compute
    module_function

    #=========================================================================
    # 休日の計算
    #
    # @param:  year
    # @param:  month
    # @param:  day
    # @return: holiday (漢字１文字)
    #=========================================================================
    def compute_holiday(year, month, day)
      holidays = get_holidays(year)
      code = 99
      holidays.each do |holiday|
        if holiday[0] == month &&  holiday[1] == day
          code = holiday[2]
          break
        end
      end
      holiday = ""
      res = Const::HOLIDAY.select { |h| h[0] == code }
      holiday = res[0][6] unless res == []
      return holiday
    end

    #=========================================================================
    # 年間休日一覧の取得
    #
    # @param:  year
    # @return: holidays (年間休日の配列)
    #=========================================================================
    def get_holidays(year)
      holiday_0 = Array.new  # 変動の祝日用
      holiday_1 = Array.new  # 国民の休日用
      holiday_2 = Array.new  # 振替休日用

      # 変動の祝日の日付･曜日を計算 ( 振替休日,国民の休日を除く )
      Const::HOLIDAY.each do |id, month, day, kbn, year_s, year_e, name|
        next if kbn > 7
        next if year < year_s || year_e < year
        if kbn == 0   # 月日が既定のもの
          jd_jst = gc2jd(year, month, day)
          yobi = compute_yobi(jd_jst)
          holiday_0 << [month, day, id, jd_jst, yobi]
        else          # 月日が不定のもの
          case kbn
          when 2      # 第2月曜日 ( 8 - 14 の月曜日)
            8.upto(14) do |d|
              jd_jst = gc2jd(year, month, d)
              yobi = compute_yobi(jd_jst)
              if yobi == "月"
                holiday_0 << [month, d, id, jd_jst, yobi]
                break
              end
            end
          when 3      # 第3月曜日 ( 15 - 21 の月曜日)
            15.upto(21) do |d|
              jd_jst = gc2jd(year, month, d)
              yobi = compute_yobi(jd_jst)
              if yobi == "月"
                holiday_0 << [month, d, id, jd_jst, yobi]
                break
              end
            end
          when 4  # 二分（春分、秋分）
            jd_jst = gc2jd(year, month, 30)
            nibun_jd = get_last_nc(jd_jst, 90)[0]
            d = jd2ymd(nibun_jd - 0.125)[2]
            wk_jd = gc2jd(year, month, d)
            yobi = compute_yobi(wk_jd)
            holiday_0 << [month, d, id, wk_jd, yobi]
          end
        end
      end

      # 国民の休日計算
      # ( 「国民の祝日」で前後を挟まれた「国民の祝日」でない日 )
      # ( 年またぎは考慮していない(今のところ不要) )
      year_s_k = Const::HOLIDAY.select { |a| a[0] == 90 }[0][4]
      0.upto(holiday_0.length - 2) do |i|
        m_0, d_0 = holiday_0[i    ][0, 2]
        m_1, d_1 = holiday_0[i + 1][0, 2]
        jd_0 = gc2jd(year, m_0, d_0)
        jd_1 = gc2jd(year, m_1, d_1)
        if jd_0 + 2 == jd_1
          jd = jd_0 + 1
          m, d = jd2ymd(jd)[1, 2]
          yobi = Const::YOBI[Const::YOBI.index(holiday_0[i][4]) + 1]
          holiday_1 << [m, d, 90, jd, yobi]
        end
      end if year < year_s_k

      # 振替休日計算
      # ( 「国民の祝日」が日曜日に当たるときは、
      #   その日後においてその日に最も近い「国民の祝日」でない日 )
      year_s_f = Const::HOLIDAY.select { |a| a[0] == 91 }[0][4]
      0.upto(holiday_0.length - 1) do |i|
        if holiday_0[i][4] == "日"
          next_jd = holiday_0[i][3] + 1
          next_yobi = Const::YOBI[Const::YOBI.index(holiday_0[i][4]) + 1]
          if i == holiday_0.length - 1
            wk_ymd = jd2ymd(next_jd)
            wk_ary = [wk_ymd[1], wk_ymd[2], 91, next_jd, next_yobi]
          else
            flg_furikae = 0
            plus_day = 1
            while flg_furikae == 0
              if i + plus_day < holiday_0.length
                if next_jd == holiday_0[i + plus_day][3]
                  next_jd += 1
                  next_yobi = next_yobi == "土" ? "日" :
                              Const::YOBI[Const::YOBI.index(next_yobi) + 1]
                  plus_day += 1
                else
                  flg_furikae = 1
                  wk_ymd = jd2ymd(next_jd)
                  wk_ary =[wk_ymd[1], wk_ymd[2], 91, next_jd, next_yobi]
                end
              end
            end
          end
          holiday_2 << wk_ary
        end
      end if year < year_s_f
      return (holiday_0 + holiday_1 + holiday_2).sort
    end

    #=========================================================================
    # 二十四節気の計算
    #
    # @param:  jd (ユリウス日(JST))
    # @return: sekki_24 (二十四節気の文字列)
    #=========================================================================
    def compute_sekki_24(jd)
      ymd = jd2ymd(jd)[0, 3]
      res = @sekki24_tms.select do |row|
        row[0, 3].map(&:to_i) == ymd
      end[0]
      return res ? Const::SEKKI_24[res[6].to_i / 15] : ""
    end

    #=========================================================================
    # 雑節の計算
    #
    # @param:  jd (ユリウス日(JST))
    # @return: [雑節コード1, 雑節コード2]
    #=========================================================================
    def compute_zassetsu(jd)
      zassetsu = Array.new

      # 計算対象日の太陽の黄経
      lsun_today = compute_lambda(jd)
      # 計算対象日の翌日の太陽の黄経
      lsun_tomorrow = compute_lambda(jd + 1)
      # 計算対象日の5日前の太陽の黄経(社日計算用)
      lsun_before_5 = compute_lambda(jd - 5)
      # 計算対象日の4日前の太陽の黄経(社日計算用)
      lsun_before_4 = compute_lambda(jd - 4)
      # 計算対象日の5日後の太陽の黄経(社日計算用)
      lsun_after_5  = compute_lambda(jd + 5)
      # 計算対象日の6日後の太陽の黄経(社日計算用)
      lsun_after_6  = compute_lambda(jd + 6)
      # 太陽の黄経の整数部分( 土用, 入梅, 半夏生 計算用 )
      lsun_today0    = lsun_today.truncate
      lsun_tomorrow0 = lsun_tomorrow.truncate

      #### ここから各種雑節計算
      # 0:節分 ( 立春の前日 )
      zassetsu << 0 if compute_sekki_24(jd + 1) == "立春"
      # 1:彼岸入（春） ( 春分の日の3日前 )
      zassetsu << 1 if compute_sekki_24(jd + 3) == "春分"
      # 2:彼岸（春） ( 春分の日 )
      zassetsu << 2 if compute_sekki_24(jd) == "春分"
      # 3:彼岸明（春） ( 春分の日の3日後 )
      zassetsu << 3 if compute_sekki_24(jd - 3) == "春分"
      # 4:社日（春） ( 春分の日に最も近い戊(つちのえ)の日 )
      # * 計算対象日が戊の日の時、
      #   * 4日後までもしくは4日前までに春分の日がある時、
      #       この日が社日
      #   * 5日後が春分の日の時、
      #       * 春分点(黄経0度)が午前なら
      #           この日が社日
      #       * 春分点(黄経0度)が午後なら
      #           この日の10日後が社日
      if (jd % 10).truncate == 4  # 戊の日
        # [ 当日から4日後 ]
        0.upto(4) do |i|
          if compute_sekki_24(jd + i) == "春分"
            zassetsu << 4
            break
          end
        end
        # [ 1日前から4日前 ]
        1.upto(4) do |i|
          if compute_sekki_24(jd - i) == "春分"
            zassetsu << 4
            break
          end
        end
        # [ 5日後 ]
        if compute_sekki_24(jd + 5)  == "春分"
          # 春分の日の黄経(太陽)と翌日の黄経(太陽)の中間点が
          # 0度(360度)以上なら、春分点が午前と判断
          zassetsu << 4 if (lsun_after_5 + lsun_after_6 + 360) / 2.0 >= 360
        end
        # [ 5日前 ]
        if compute_sekki_24(jd - 5) == "春分"
          # 春分の日の黄経(太陽)と翌日の黄経(太陽)の中間点が
          # 0度(360度)未満なら、春分点が午後と判断
          zassetsu << 4 if (lsun_before_4 + lsun_before_5 + 360) / 2.0 < 360
        end
      end
      # 5:土用入（春） ( 黄経(太陽) = 27度 )
      unless lsun_today0 == lsun_tomorrow0
        zassetsu << 5 if lsun_tomorrow0 == 27
      end
      # 6:八十八夜 ( 立春から88日目(87日後) )
      zassetsu << 6 if compute_sekki_24(jd - 87) == "立春"
      # 7:入梅 ( 黄経(太陽) = 80度 )
      unless lsun_today0 == lsun_tomorrow0
        zassetsu << 7 if lsun_tomorrow0 == 80
      end
      # 8:半夏生  ( 黄経(太陽) = 100度 )
      unless lsun_today0 == lsun_tomorrow0
        zassetsu << 8 if lsun_tomorrow0 == 100
      end
      # 9:土用入（夏） ( 黄経(太陽) = 117度 )
      unless lsun_today0 == lsun_tomorrow0
        zassetsu << 9 if lsun_tomorrow0 == 117
      end
      # 10:二百十日 ( 立春から210日目(209日後) )
      zassetsu << 10 if compute_sekki_24(jd - 209) == "立春"
      # 11:二百二十日 ( 立春から220日目(219日後) )
      zassetsu << 11 if compute_sekki_24(jd - 219) == "立春"
      # 12:彼岸入（秋） ( 秋分の日の3日前 )
      zassetsu << 12 if compute_sekki_24(jd + 3) == "秋分"
      # 13:彼岸（秋） ( 秋分の日 )
      zassetsu << 13 if compute_sekki_24(jd) == "秋分"
      # 14:彼岸明（秋） ( 秋分の日の3日後 )
      zassetsu << 14 if compute_sekki_24(jd - 3) == "秋分"
      # 15:社日（秋） ( 秋分の日に最も近い戊(つちのえ)の日 )
      # * 計算対象日が戊の日の時、
      #   * 4日後までもしくは4日前までに秋分の日がある時、
      #       この日が社日
      #   * 5日後が秋分の日の時、
      #       * 秋分点(黄経180度)が午前なら
      #           この日が社日
      #       * 秋分点(黄経180度)が午後なら
      #           この日の10日後が社日
      if (jd % 10).truncate == 4 # 戊の日
        # [ 当日から4日後 ]
        0.upto(4) do |i|
          if compute_sekki_24(jd + i) == "秋分"
            zassetsu << 15
            break
          end
        end
        # [ 1日前から4日前 ]
        1.upto(4) do |i|
          if compute_sekki_24(jd - i) == "秋分"
            zassetsu << 15
            break
          end
        end
        # [ 5日後 ]
        if compute_sekki_24(jd + 5) == "秋分"
          # 秋分の日の黄経(太陽)と翌日の黄経(太陽)の中間点が
          # 180度以上なら、秋分点が午前と判断
          zassetsu << 15 if (lsun_after_5 + lsun_after_6) / 2.0 >= 180
        end
        # [ 5日前 ]
        if compute_sekki_24(jd - 5) == "秋分"
          # 秋分の日の黄経(太陽)と翌日の黄経(太陽)の中間点が
          # 180度未満なら、秋分点が午後と判断
          zassetsu << 15 if (lsun_before_4 + lsun_before_5) / 2.0 < 180
        end
      end
      # 16:土用入（秋） ( 黄経(太陽) = 207度 )
      unless lsun_today0 == lsun_tomorrow0
        zassetsu << 16 if lsun_tomorrow0 == 207
      end
      # 17:土用入（冬） ( 黄経(太陽) = 297度 )
      unless lsun_today0 == lsun_tomorrow0
        zassetsu << 17 if lsun_tomorrow0 == 297
      end
      return zassetsu.map { |z| Const::ZASSETSU[z] }.join(",")
    end

    #=========================================================================
    # 曜日の計算
    #
    # * 曜日 = ( ユリウス通日 + 2 ) % 7
    #     0: 日曜, 1: 月曜, 2: 火曜, 3: 水曜, 4: 木曜, 5: 金曜, 6: 土曜
    #
    # @param:  jd (ユリウス日(JST))
    # @return: yobi  (漢字１文字)
    #=========================================================================
    def compute_yobi(jd)
      return Const::YOBI[(jd.to_i + 2) % 7]
    end

    #=========================================================================
    # 干支の計算
    #
    # * [ユリウス日(JST) - 10日] を60で割った剰余
    #
    # @param:  jd (ユリウス日(JST))
    # @return  kanshi (漢字２文字)
    #=========================================================================
    def compute_kanshi(jd)
      return Const::KANSHI[(jd.to_i - 10) % 60]
    end

    #=========================================================================
    # 節句の計算
    #
    # @param:  month
    # @param:  day
    # @return: sekku (日本語文字列)
    #=========================================================================
    def compute_sekku(month, day)
      sekku = ""
      res = Const::SEKKU.select { |s| s[1] == month && s[2] == day }
      sekku = res[0][3] unless res == []
      return sekku
    end

    #=========================================================================
    # 月齢(正午)の計算
    #
    # @param:  jd (ユリウス日(JST))
    # @return: moonage
    #=========================================================================
    def compute_moonage(jd)
      return jd - get_last_saku(jd)
    end

    #=========================================================================
    # 旧暦の計算
    #
    # * 旧暦一日の六曜
    #     １・７月   : 先勝
    #     ２・８月   : 友引
    #     ３・９月   : 先負
    #     ４・１０月 : 仏滅
    #     ５・１１月 : 大安
    #     ６・１２月 : 赤口
    #   と決まっていて、あとは月末まで順番通り。
    #   よって、月と日をたした数を６で割った余りによって六曜を決定することができます。
    #   ( 旧暦の月 ＋ 旧暦の日 ) ÷ 6 ＝ ？ … 余り
    #   余り 0 : 大安
    #        1 : 赤口
    #        2 : 先勝
    #        3 : 友引
    #        4 : 先負
    #        5 : 仏滅
    #
    # @param:  jd (ユリウス日(JST))
    # @return: [旧暦年, 閏月Flag, 旧暦月, 旧暦日, 六曜]
    #=========================================================================
    def compute_oc(jd)
      jd -= 0.5
      tm0 = jd
      # 二分二至,中気の時刻･黄経用配列宣言
      chu = Array.new(4).map { Array.new(2, 0) }
      # 朔用配列宣言
      saku = Array.new(5, 0)
      # 朔日用配列宣言
      m = Array.new(5).map { Array.new(3, 0) }
      # 旧暦用配列宣言
      kyureki = Array.new(4, 0)

      # 計算対象の直前にあたる二分二至の時刻を計算
      #   chu[0][0] : 二分二至の時刻
      #   chu[0][1] : その時の太陽黄経
      chu[0] = get_last_nc(tm0, 90)
      # 中気の時刻を計算 ( 3回計算する )
      #   chu[i][0] : 中気の時刻
      #   chu[i][1] : その時の太陽黄経
      1.upto(3) do |i|
        chu[i] = get_last_nc(chu[i - 1][0] + 32, 30)
      end
      # 計算対象の直前にあたる二分二至の直前の朔の時刻を求める
      saku[0] = get_last_saku(chu[0][0])
      # 朔の時刻を求める
      1.upto(4) do |i|
        tm = saku[i-1] + 30
        saku[i] = get_last_saku(tm)
        # 前と同じ時刻を計算した場合( 両者の差が26日以内 )には、初期値を
        # +33日にして再実行させる。
        if (saku[i-1].truncate - saku[i].truncate).abs <= 26
          saku[i] = get_last_saku(saku[i-1] + 35)
        end
      end
      # saku[1]が二分二至の時刻以前になってしまった場合には、朔をさかのぼり過ぎ
      # たと考えて、朔の時刻を繰り下げて修正する。
      # その際、計算もれ（saku[4]）になっている部分を補うため、朔の時刻を計算
      # する。（近日点通過の近辺で朔があると起こる事があるようだ...？）
      if saku[1].truncate <= chu[0][0].truncate
        0.upto(3) { |i| saku[i] = saku[i+1] }
        saku[4] = get_last_saku(saku[3] + 35)
      # saku[0]が二分二至の時刻以後になってしまった場合には、朔をさかのぼり足
      # りないと見て、朔の時刻を繰り上げて修正する。
      # その際、計算もれ（saku[0]）になっている部分を補うため、朔の時刻を計算
      # する。（春分点の近辺で朔があると起こる事があるようだ...？）
      elsif saku[0].truncate > chu[0][0].truncate
        4.downto(1) { |i| saku[i] = saku[i-1] }
        saku[0] = get_last_saku(saku[0] - 27)
      end
      # 閏月検索Flagセット
      # （節月で４ヶ月の間に朔が５回あると、閏月がある可能性がある。）
      # leap=0:平月  leap=1:閏月
      leap = 0
      leap = 1 if saku[4].truncate <= chu[3][0].truncate
      # 朔日行列の作成
      # m[i][0] ... 月名 ( 1:正月 2:２月 3:３月 .... )
      # m[i][1] ... 閏フラグ ( 0:平月 1:閏月 )
      # m[i][2] ... 朔日のjd
      m[0][0] = (chu[0][1] / 30.0).truncate + 2
      m[0][0] -= 12 if m[0][0] > 12
      m[0][2] = saku[0].truncate
      m[0][1] = 0
      1.upto(4) do |i|
        if leap == 1 && i != 1
          if chu[i-1][0].truncate <= saku[i-1].truncate ||
             chu[i-1][0].truncate >= saku[i].truncate
            m[i-1][0] = m[i-2][0]
            m[i-1][1] = 1
            m[i-1][2] = saku[i-1].truncate
            leap = 0
          end
        end
        m[i][0] = m[i-1][0] + 1
        m[i][0] -= 12 if m[i][0] > 12
        m[i][2] = saku[i].truncate
        m[i][1] = 0
      end
      # 朔日行列から旧暦を求める。
      state, index = 0, 0
      0.upto(4) do |i|
        index = i
        if tm0.truncate < m[i][2].truncate
          state = 1
          break
        elsif tm0.truncate == m[i][2].truncate
          state = 2
          break
        end
      end
      index -= 1 if state == 1
      kyureki[1] = m[index][1]
      kyureki[2] = m[index][0]
      kyureki[3] = tm0.truncate - m[index][2].truncate + 1
      # 旧暦年の計算
      # （旧暦月が10以上でかつ新暦月より大きい場合には、
      #   まだ年を越していないはず...）
      a = jd2ymd(tm0)
      kyureki[0] = a[0]
      kyureki[0] -= 1 if kyureki[2] > 9 && kyureki[2] > a[1]
      # 六曜
      kyureki[4] = Const::ROKUYO[(kyureki[2] + kyureki[3]) % 6]
      return kyureki
    end

    #=========================================================================
    # 直前二分二至・中気時刻の取得
    #
    # @param: jd  (ユリウス日)
    # @param: kbn (90: 二分二至, 30: 中気)
    # @return: [二分二至・中気の時刻, その時の黄経]
    #=========================================================================
    def get_last_nc(jd, kbn)
      sekki24_tms = @sekki24_tms.select { |s| s[6].to_i % kbn == 0}
      jd -= 0.125
      ymd = jd2ymd(jd)
      str_target = sprintf("%04d-%02d-%02d %02d:%02d:%02d %3d", *ymd, kbn)
      sekki24_tms.reverse.each do |row|
        str = sprintf("%04d-%02d-%02d %02d:%02d:%02d", *row[0, 6])
        unless str[0, 19] > str_target
          year, month, day, hour, min, sec = row[0, 6].map(&:to_i)
          return [gc2jd(year, month, day, hour, min, sec), row[6].to_i]
        end
      end
      return []
    end

    #=========================================================================
    # 直近の朔の時刻（JST）の取得
    #
    # @param:  jd (ユリウス日)
    # @return: saku (直前の朔の時刻)
    #=========================================================================
    def get_last_saku(jd)
      ymd = jd2ymd(jd)
      str_target = sprintf("%04d-%02d-%02d %02d:%02d:%02d", *ymd)
      @saku_tms.reverse.each do |row|
        str = sprintf("%04d-%02d-%02d %02d:%02d:%02d", *row)
        unless str[0, 19] > str_target
          year, month, day, hour, min, sec = row.map(&:to_i)
          return gc2jd(year, month, day, hour, min, sec) - 0.125
        end
      end
      return []
    end

    #=========================================================================
    # Gregorian Calendar -> Julian Day
    #
    # * フリーゲルの公式を使用する
    #   [ JD ] = int( 365.25 × year )
    #          + int( year / 400 )
    #          - int( year / 100 )
    #          + int( 30.59 ( month - 2 ) )
    #          + day
    #          + 1721088
    #   ※上記の int( x ) は厳密には、x を超えない最大の整数
    #     ( ちなみに、[ 準JD ]を求めるなら + 1721088.5 が - 678912 となる )
    #
    # @param:  year
    # @param:  month
    # @param:  day
    # @param:  hour
    # @param:  minute
    # @param:  second
    # @return: jd ( ユリウス日 )
    #=========================================================================
    def gc2jd(year, month, day, hour = 0, min = 0, sec = 0)
      # 1月,2月は前年の13月,14月とする
      if month < 3
        year  -= 1
        month += 12
      end
      # 日付(整数)部分計算
      jd  = (365.25 * year).truncate
      jd += (year / 400.0).truncate
      jd -= (year / 100.0).truncate
      jd += (30.59 * (month - 2)).truncate
      jd += day
      jd += 1721088.125
      # 時間(小数)部分計算
      t  = sec / 3600.0
      t += min / 60.0
      t += hour
      t  = t / 24.0
      return jd + t
    end

    #=========================================================================
    # Julian Day -> UT
    #
    # @param: jd (ユリウス日)
    # @return: [year, month, day, hour, minute, second]
    #=========================================================================
    def jd2ymd(jd)
      ut = Array.new(6, 0)
      x0 = (jd + 68570).truncate
      x1 = (x0 / 36524.25).truncate
      x2 = x0 - (36524.25 * x1 + 0.75).truncate
      x3 = ((x2 + 1) / 365.2425).truncate
      x4 = x2 - (365.25 * x3).truncate + 31
      x5 = (x4.truncate / 30.59).truncate
      x6 = (x5.truncate / 11.0).truncate
      ut[2] = x4 - (30.59 * x5).truncate
      ut[1] = x5 - 12 * x6 + 2
      ut[0] = 100 * (x1 - 49) + x3 + x6
      # 2月30日の補正
      if ut[1]==2 && ut[2] > 28
        if ut[0] % 100 == 0 && ut[0] % 400 == 0
          ut[2] = 29
        elsif ut[0] % 4 == 0
          ut[2] = 29
        else
          ut[2] = 28
        end
      end
      tm = 86400 * (jd - jd.truncate)
      ut[3] = (tm / 3600.0).truncate
      ut[4] = ((tm - 3600 * ut[3]) / 60.0).truncate
      #ut[5] = (tm - 3600 * ut[3] - 60 * ut[4]).truncate
      ut[5] = tm - 3600 * ut[3] - 60 * ut[4]
      return ut
    end

    #=========================================================================
    # 角度の正規化
    #
    # @param:  angle
    # @return: angle
    #=========================================================================
    def norm_angle(angle)
      if angle < 0
        angle1  = angle * (-1)
        angle2  = (angle1 / 360.0).truncate
        angle1 -= 360 * angle2
        angle1  = 360 - angle1
      else
        angle1  = (angle / 360.0).truncate
        angle1  = angle - 360.0 * angle1
      end
      return angle1
    end

    #=========================================================================
    # ΔT の計算
    #
    # * 1972-01-01 以降、うるう秒挿入済みの年+αまでは、以下で算出
    #     TT - UTC = ΔT + DUT1 = TAI + 32.184 - UTC = ΔAT + 32.184
    #   [うるう秒実施日一覧](http://jjy.nict.go.jp/QandA/data/leapsec.html)
    #
    # @param:  year
    # @param:  month
    # @param:  day
    # @return: dt
    #=========================================================================
    def compute_dt(year, month, day)
      ymd = sprintf("%04d%02d%02d", year, month, day)
      tm = MkTime.new(ymd)
      return tm.dt
    end

    #=========================================================================
    # 六曜の計算
    #
    #
    # @param:  oc_month (旧暦の月)
    # @param:  oc_day   (旧暦の日)
    # @return: rokuyo (漢字2文字)
    #=========================================================================
    def compute_rokuyo(oc_month, oc_day)
      return Const::ROKUYO[(oc_month + oc_day) % 6]
    end

    #=========================================================================
    # 太陽視黄経の計算
    #
    # @param:  jd (ユリウス日(JST))
    # @return: lambda
    #=========================================================================
    def compute_lambda(jd)
      year, month, day, hour, min, sec = jd2ymd(jd - Const::JST_D - 0.5)
      ymd = sprintf("%04d%02d%02d%02d%02d%08d", year, month, day, hour, min, sec * 10 ** 6)
      a = MkApos.new(@bin_path, ymd)
      lmd = a.sun[1][0] * 180.0 / Math::PI
      return lmd
    end

    #=========================================================================
    # 月視黄経の計算
    #
    # @param:  jd (ユリウス日(JST))
    # @return: lambda
    #=========================================================================
    def compute_alpha(jd)
      year, month, day, hour, min, sec = jd2ymd(jd - Const::JST_D - 0.5)
      ymd = sprintf("%04d%02d%02d%02d%02d%08d", year, month, day, hour, min, sec * 10 ** 6)
      a = MkApos.new(@bin_path, ymd)
      lmd = a.moon[1][0] * 180.0 / Math::PI
      return lmd
    end
  end
end

