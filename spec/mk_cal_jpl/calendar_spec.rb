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
    it { expect(subject).to be_within(1.0e-4).of(67.4564) }
  end

  context ".moonage" do
    let(:c) { MkCalJpl::Calendar.new(BIN_PATH, [2016, 6, 5]) }
    subject { c.moonage }
    it { expect(subject).to be_within(1.0e-2).of(29.31) }
  end

  context ".oc (case: non-leap)" do
    let(:c) { MkCalJpl::Calendar.new(BIN_PATH, [2016, 6, 5]) }
    subject { c.oc }
    it { expect(subject).to match([2016, 0, 5, 1, "大安"]) }
  end

  context ".oc (case: leap)" do
    let(:c) { MkCalJpl::Calendar.new(BIN_PATH, [2014, 10, 27]) }
    subject { c.oc }
    it { expect(subject).to match([2014, 1, 9, 4, "赤口"]) }
  end
end

