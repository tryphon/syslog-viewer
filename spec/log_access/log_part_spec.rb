require 'spec_helper'

describe LogAccess::LogPart do

  let(:file) { LogFabricator.new.create }
  subject { LogAccess::LogPart.new(file) }

  describe "#lines" do

    it "should be empty before loading" do
      subject.lines.should be_empty
    end

  end

  describe "#last_position" do

    before do
      subject.load
    end

    it "should be the last read position" do
      subject.last_position.should == File.size(file)
    end

  end

  describe "first_line" do

    it "should be nil by default" do
      subject.first_line.should be_nil
    end

    context "after loading" do
      before do
        subject.load
      end

      it "should contain first log line (to detect logrotate)" do
        subject.first_line.should == File.readlines(file).first
      end
    end

  end

  describe "#lines" do

    it "should be empty by default" do
      subject.lines.should be_empty
    end

    context "after loading" do

      before do
        subject.load
      end

      it "should contain (last/filtered) file lines" do
        subject.lines.should == File.readlines(file).map(&:strip)
      end

    end

  end

  describe "#filter" do

    it "should be nil by default" do
      subject.filter.should be_nil
    end

    context "when defined" do
      it "should be use in loading to filter lines" do
        subject.filter = "NetworkManager"
        subject.load

        subject.lines.each do |line|
          line.should match(subject.filter)
        end
      end
    end

  end

  describe "#first_line_tag" do

    it "should be nil if first_line isn't defined" do
      subject.first_line_tag.should be_nil
    end

    it "should be the sha1 hex digest of first line" do
      subject.first_line = "dummy"
      subject.first_line_tag.should == "829c3804401b0727f70f73d4415e162400cbe57b"
    end

  end

end
