require "spec_helper"

describe MkCalJpl::Argument do
  context %Q{.new("#{BIN_PATH}", "20170226") } do
    let(:a) { described_class.new(BIN_PATH, "20170226") }

    context "object" do
      it { expect(a).to be_an_instance_of(described_class) }
    end

    context ".get_args" do
      subject { a.get_args }
      it { expect(subject).to match([BIN_PATH, [2017, 2, 26]]) }
    end

    context ".get_binpath" do
      subject { a.send(:get_binpath) }
      it { expect(subject).to eq BIN_PATH }
    end

    context ".check_bin_path" do
      let(:bin_path) { a.send(:get_binpath) }
      subject { a.send(:check_bin_path, bin_path) }
      it { expect(subject).to eq nil }
    end

    context ".get_jst" do
      subject do
        a.send(:get_binpath)
        a.send(:get_jst)
      end
      it { expect(subject).to match([2017, 2, 26]) }
    end
  end

  context ".new" do
    let(:a) { described_class.new }

    context ".get_args" do
      subject { a.get_args }
      it { expect{subject}.to raise_error(MkCalJpl::Const::USAGE) }
    end

    context ".get_binpath" do
      subject { a.send(:get_binpath) }
      it { expect{subject}.to raise_error(MkCalJpl::Const::USAGE) }
    end
  end

  context %Q{.new("#{BIN_DUMMY}", "20170226") } do
    let(:a) { described_class.new(BIN_DUMMY, "20170226") }

    context ".check_bin_path" do
      let(:bin_path) { a.send(:get_binpath) }
      subject { a.send(:check_bin_path, bin_path) }
      it { expect{subject}.to raise_error(MkCalJpl::Const::MSG_ERR_1) }
    end
  end

  context %Q{.new("#{BIN_PATH}", "20170226A") } do
    let(:a) { described_class.new(BIN_PATH, "20170226A") }

    context ".get_args" do
      subject { a.get_args }
      it { expect{subject}.to raise_error(MkCalJpl::Const::MSG_ERR_2) }
    end

    context ".get_jst" do
      subject do
        a.send(:get_binpath)
        a.send(:get_jst)
      end
      it { expect{subject}.to raise_error(MkCalJpl::Const::MSG_ERR_2) }
    end
  end

  context %Q{.new("#{BIN_PATH}", "20160931") } do
    let(:a) { described_class.new(BIN_PATH, "20160931") }

    context ".get_args" do
      subject { a.get_args }
      it { expect{subject}.to raise_error(MkCalJpl::Const::MSG_ERR_3) }
    end

    context ".get_jst" do
      subject do
        a.send(:get_binpath)
        a.send(:get_jst)
      end
      it { expect{subject}.to raise_error(MkCalJpl::Const::MSG_ERR_3) }
    end
  end
end

