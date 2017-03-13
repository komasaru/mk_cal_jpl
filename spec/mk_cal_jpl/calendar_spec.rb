require "spec_helper"

describe MkCalJpl::Calendar do
  context ".new(BIN_PATH, [2017, 2, 26])" do
    let(:c) { MkCalJpl::Calendar.new(BIN_PATH, [2017, 2, 26]) }

    context "object" do
      it { expect(c).to be_an_instance_of(MkCalJpl::Calendar) }
    end

    context "year" do
      it { expect(c.instance_variable_get(:@year)).to eq 2017 }
    end

    context "month" do
      it { expect(c.instance_variable_get(:@month)).to eq 2 }
    end

    context "day" do
      it { expect(c.instance_variable_get(:@day)).to eq 26 }
    end

    context "jd" do
      let(:year)  { c.instance_variable_get(:@year)  }
      let(:month) { c.instance_variable_get(:@month) }
      let(:day)   { c.instance_variable_get(:@day)   }
      subject { c.send(:gc2jd, year, month, day) }
      before { subject }
      it { expect(c.jd).to be_within(1.0e-3).of(2457810.125) }
    end
  end

  context ".holidays" do
    let(:c) { MkCalJpl::Calendar.new(BIN_PATH, [2016, 5, 3]) }
    subject { c.holidays }
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

  context ".holiday (case: holiday)" do
    let(:c) { MkCalJpl::Calendar.new(BIN_PATH, [2016, 5, 3]) }
    subject { c.holiday }
    it { expect(subject).to eq "憲法記念日" }
  end

  context ".holiday (case: holiday(振替休日))" do
    let(:c) { MkCalJpl::Calendar.new(BIN_PATH, [2016, 3, 21]) }
    subject { c.holiday }
    it { expect(subject).to eq "振替休日" }
  end

  context ".holiday (case: holiday(国民の休日))" do
    let(:c) { MkCalJpl::Calendar.new(BIN_PATH, [2009, 9, 22]) }
    subject { c.holiday }
    it { expect(subject).to eq "国民の休日" }
  end

  context ".holiday (case: non-holiday)" do
    let(:c) { MkCalJpl::Calendar.new(BIN_PATH, [2016, 6, 5]) }
    subject { c.holiday }
    it { expect(subject).to eq "" }
  end

  context ".sekki_24 (case: sekki_24)" do
    let(:c) { MkCalJpl::Calendar.new(BIN_PATH, [2016, 6, 5]) }
    subject { c.sekki_24 }
    it { expect(subject).to eq "芒種" }
  end

  context ".sekki_24 (case: non-sekki_24)" do
    let(:c) { MkCalJpl::Calendar.new(BIN_PATH, [2016, 6, 6]) }
    subject { c.sekki_24 }
    it { expect(subject).to eq "" }
  end

  context ".zassetsu (case: one-zassetsu)" do
    let(:c) { MkCalJpl::Calendar.new(BIN_PATH, [2016, 6, 10]) }
    subject { c.zassetsu }
    it { expect(subject).to eq "入梅" }
  end

  context ".zassetsu (case: two-zassetsu)" do
    let(:c) { MkCalJpl::Calendar.new(BIN_PATH, [2016, 3, 17]) }
    subject { c.zassetsu }
    it { expect(subject).to eq "彼岸入(春),社日(春)" }
  end

  context ".zassetsu (case: non-zassetsu)" do
    let(:c) { MkCalJpl::Calendar.new(BIN_PATH, [2016, 6, 5]) }
    subject { c.zassetsu}
    it { expect(subject).to eq "" }
  end

  context ".yobi" do
    let(:c) { MkCalJpl::Calendar.new(BIN_PATH, [2016, 6, 6]) }
    subject { c.yobi }
    it { expect(subject).to eq "月" }
  end

  context ".kanshi" do
    let(:c) { MkCalJpl::Calendar.new(BIN_PATH, [2016, 6, 5]) }
    subject { c.kanshi }
    it { expect(subject).to eq "戊午" }
  end

  context ".sekku (case: sekku)" do
    let(:c) { MkCalJpl::Calendar.new(BIN_PATH, [2016, 5, 5]) }
    subject { c.sekku }
    it { expect(subject).to eq "端午" }
  end

  context ".sekku (case: non-sekku)" do
    let(:c) { MkCalJpl::Calendar.new(BIN_PATH, [2016, 5, 6]) }
    subject { c.sekku }
    it { expect(subject).to eq "" }
  end

  context ".lambda" do
    let(:c) { MkCalJpl::Calendar.new(BIN_PATH, [2016, 6, 5]) }
    subject { c.lambda }
    it { expect(subject).to be_within(1.0e-4).of(74.4091) }
  end

  context ".alpha" do
    let(:c) { MkCalJpl::Calendar.new(BIN_PATH, [2016, 6, 5]) }
    subject { c.alpha }
    it { expect(subject).to be_within(1.0e-4).of(67.4573) }
  end

  context ".moonage" do
    let(:c) { MkCalJpl::Calendar.new(BIN_PATH, [2016, 6, 5]) }
    subject { c.moonage }
    it { expect(subject).to be_within(1.0e-2).of(0.00) }
  end

  context ".oc (case: non-leap)" do
    let(:c) { MkCalJpl::Calendar.new(BIN_PATH, [2017, 2, 26]) }
    subject { c.oc }
    it { expect(subject).to match([2017, 0, 2, 1, "友引"]) }
  end

  context ".oc (case: leap)" do
    let(:c) { MkCalJpl::Calendar.new(BIN_PATH, [2014, 10, 27]) }
    subject { c.oc }
    it { expect(subject).to match([2014, 1, 9, 4, "赤口"]) }
  end
end

