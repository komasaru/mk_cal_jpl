require "spec_helper"

describe MkCalJpl::Compute do
  let(:c) { MkCalJpl::Compute }

  context ".compute_holiday (1)" do
    subject do
      c.instance_variable_set(:@bin_path, BIN_PATH)
      c.instance_variable_set(:@sekki24_tms, MkCalJpl::Const::SEKKI_24_TM.each_slice(7).to_a)
      c.compute_holiday(2016, 5, 3)
    end
    it { expect(subject).to eq "憲法記念日" }
  end

  context ".compute_holiday (2)" do
    subject { c.compute_holiday(2016, 5, 5) }
    it { expect(subject).to eq "こどもの日" }
  end

  context ".compute_holiday (3)" do
    subject { c.compute_holiday(2016, 6, 5) }
    it { expect(subject).to eq "" }
  end

  context ".compute_holiday (4)" do
    subject { c.compute_holiday(2016, 6, 5) }
    it { expect(subject).to eq "" }
  end

  context ".get_holidays" do
    subject { c.get_holidays(2016) }
    it { expect(subject).to match([
      [ 1,  1,  0, 2457388.125, "金"], [ 1, 11,  1, 2457398.125, "月"],
      [ 2, 11,  2, 2457429.125, "木"], [ 3, 20,  3, 2457467.125, "日"],
      [ 3, 21, 91, 2457468.125, "月"], [ 4, 29,  4, 2457507.125, "金"],
      [ 5,  3,  5, 2457511.125, "火"], [ 5,  4,  6, 2457512.125, "水"],
      [ 5,  5,  7, 2457513.125, "木"], [ 7, 18,  8, 2457587.125, "月"],
      [ 8, 11,  9, 2457611.125, "木"], [ 9, 19, 10, 2457650.125, "月"],
      [ 9, 22, 11, 2457653.125, "木"], [10, 10, 12, 2457671.125, "月"],
      [11,  3, 13, 2457695.125, "木"], [11, 23, 14, 2457715.125, "水"],
      [12, 23, 15, 2457745.125, "金"]
    ]) }
  end

  context ".compute_sekki_24 (1)" do
    subject { c.compute_sekki_24(2457544.5) }  # 2016-06-05
    it { expect(subject).to eq "芒種" }
  end

  context ".compute_sekki_24 (2)" do
    subject { c.compute_sekki_24(2457467.5) }  # 2016-03-20
    it { expect(subject).to eq "春分" }
  end

  context ".compute_sekki_24 (3)" do
    subject { c.compute_sekki_24(2457545.5) }  # 2016-06-06
    it { expect(subject).to eq "" }
  end

  context ".compute_sekki_24 (4)" do
    subject { c.compute_sekki_24(2457468.5) }  # 2016-03-21
    it { expect(subject).to eq "" }
  end

  context ".compute_zassetsu (1)" do
    subject { c.compute_zassetsu(2457549.5) }  # 2016-06-10
    it { expect(subject).to eq "入梅" }
  end

  context ".compute_zassetsu (2)" do
    subject { c.compute_zassetsu(2457464.5) }  # 2016-03-17
    it { expect(subject).to eq "彼岸入(春),社日(春)" }
  end

  context ".compute_zassetsu (3)" do
    subject { c.compute_zassetsu(2457544.5) }  # 2016-06-05
    it { expect(subject).to eq "" }
  end

  context ".compute_yobi (1)" do
    subject { c.compute_yobi(2457544.5) }  # 2016-06-05
    it { expect(subject).to eq "日" }
  end

  context ".compute_yobi (2)" do
    subject { c.compute_yobi(2457547.5) }  # 2016-06-08
    it { expect(subject).to eq "水" }
  end

  context ".compute_kanshi (1)" do
    subject { c.compute_kanshi(2457544.5) }  # 2016-06-05
    it { expect(subject).to eq "戊午" }
  end

  context ".compute_kanshi (2)" do
    subject { c.compute_kanshi(2457547.5) }  # 2016-06-08
    it { expect(subject).to eq "辛酉" }
  end

  context ".compute_sekku (1)" do
    subject { c.compute_sekku(5, 5) }
    it { expect(subject).to eq "端午" }
  end

  context ".compute_sekku (2)" do
    subject { c.compute_sekku(7, 7) }
    it { expect(subject).to eq "七夕" }
  end

  context ".compute_sekku (3)" do
    subject { c.compute_sekku(6, 8) }
    it { expect(subject).to eq "" }
  end

  context ".compute_moonage (1)" do
    subject do
      c.instance_variable_set(:@saku_tms, MkCalJpl::Const::SAKU_TM.each_slice(6).to_a)
      c.compute_moonage(2457544.5)  # 2016-06-05
    end
    it { expect(subject).to be_within(1.0e-2).of(0.00) }
  end

  context ".compute_moonage (2)" do
    subject { c.compute_moonage(2457547.5) }  # 2016-06-08
    it { expect(subject).to be_within(1.0e-2).of(3.00) }
  end

  context ".compute_oc (1)" do
    subject { c.compute_oc(2457544.5) }  # 2016-06-05
    it { expect(subject).to match([2016, 0, 5, 1, "大安"]) }
  end

  context ".compute_oc (2)" do
    subject { c.compute_oc(2457547.5) }  # 2016-06-08
    it { expect(subject).to match([2016, 0, 5, 4, "友引"]) }
  end

  context ".compute_oc (3)" do
    subject { c.compute_oc(2456957.5) }  # 2014-10-27
    it { expect(subject).to match([2014, 1, 9, 4, "赤口"]) }
  end

  context ".compute_oc (4)" do
    subject { c.compute_oc(2457572.5) }  # 2016-07-03
    it { expect(subject).to match([2016, 0, 5, 29, "先負"]) }
  end

  context ".compute_oc (5)" do
    subject { c.compute_oc(2457573.5) }  # 2016-07-04
    it { expect(subject).to match([2016, 0, 6, 1, "赤口"]) }
  end

  context ".compute_oc (6)" do
    subject { c.compute_oc(2457809.5) }  # 2017-02-25
    it { expect(subject).to match([2017, 0, 1, 29, "大安"]) }
  end

  context ".compute_oc (7)" do
    subject { c.compute_oc(2457810.5) }  # 2017-02-26
    it { expect(subject).to match([2017, 0, 2, 1, "友引"]) }
  end

  context ".compute_oc (8)" do
    subject { c.compute_oc(2457839.5) }  # 2017-03-27
    it { expect(subject).to match([2017, 0, 2, 30, "先勝"]) }
  end

  context ".compute_oc (9)" do
    subject { c.compute_oc(2457840.5) }  # 2017-03-28
    it { expect(subject).to match([2017, 0, 3, 1, "先負"]) }
  end

  context ".get_last_nc (1)" do
    subject { c.get_last_nc(2457478.0, 90) }
    it { expect(subject).to match([be_within(1.0e-4).of(2457467.6876), 0]) }
  end

  context ".get_last_nc (2)" do
    subject { c.get_last_nc(2457499.5623189886, 30) }
    it { expect(subject).to match([be_within(1.0e-4).of(2457498.1454), 30]) }
  end

  context ".get_last_saku (1)" do
    subject { c.get_last_saku(2457478.0) }
    it { expect(subject).to be_within(1.0e-4).of(2457456.4544) }
  end

  context ".get_last_saku (2)" do
    subject { c.get_last_saku(2457499.5623189886) }
    it { expect(subject).to be_within(1.0e-4).of(2457485.8497) }
  end

  context ".gc2jd" do
    subject { c.gc2jd(2016, 6, 5) }
    it { expect(subject).to eq 2457544.125 }
  end

  context ".jd2ymd" do
    subject { c.jd2ymd(2457544.5) }
    it { expect(subject).to match([2016, 6, 5, 12, 0, 0]) }
  end

  context ".norm_angle" do
    subject { c.norm_angle(1051.4215) }
    it { expect(subject).to be_within(1.0e-4).of(331.4215) }
  end

  context ".compute_dt (case: A.D.2012)" do
    subject { c.compute_dt(2012, 6, 1) }
    it { expect(subject).to be_within(1.0e-3).of(66.784) }
  end

  context ".compute_dt (case: A.D.2016)" do
    subject { c.compute_dt(2016, 6, 5) }
    it { expect(subject).to be_within(1.0e-3).of(68.384) }
  end

  context ".compute_dt (case: A.D.2030)" do
    subject { c.compute_dt(2030, 5, 21) }
    it { expect(subject).to be_within(1.0e-3).of(77.863) }
  end

  context ".compute_dt (case: A.D.1952)" do
    subject { c.compute_dt(1952, 6, 22) }
    it { expect(subject).to be_within(1.0e-3).of(30.050) }
  end

  context ".compute_dt (case: A.D.500)" do
    subject { c.compute_dt(500, 7, 25) }
    it { expect(subject).to be_within(1.0e-3).of(5704.674) }
  end

  context ".compute_rokuyo (1)" do
    subject { c.compute_rokuyo(6, 2) }
    it { expect(subject).to eq "先勝" }
  end

  context ".compute_rokuyo (2)" do
    subject { c.compute_rokuyo(6, 7) }
    it { expect(subject).to eq "赤口" }
  end

  context ".compute_lambda (1)" do
    subject { c.compute_lambda(2457544.5) }  # 2016-06-05
    it { expect(subject).to be_within(1.0e-4).of(74.4091) }
  end

  context ".compute_lambda (2)" do
    subject { c.compute_lambda(2457547.5) }  # 2016-06-08
    it { expect(subject).to be_within(1.0e-4).of(77.2812) }
  end

  context ".compute_alpha (1)" do
    subject { c.compute_alpha(2457544.5) }  # 2016-06-05
    it { expect(subject).to be_within(1.0e-4).of(67.4573) }
  end

  context ".compute_alpha (2)" do
    subject { c.compute_alpha(2457547.5) }  # 2016-06-08
    it { expect(subject).to be_within(1.0e-4).of(110.9464) }
  end
end

