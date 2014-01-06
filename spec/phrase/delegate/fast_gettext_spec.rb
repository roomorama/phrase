require 'spec_helper'

require 'phrase'
require 'phrase/delegate'
require 'phrase/adapters/fast_gettext'

describe Phrase::Delegate::FastGettext do
  before(:each) do
    Phrase::Delegate::FastGettext.stub(:log)
  end

  describe "#to_s" do
    before(:each) do
      Phrase.prefix = "{{__"
      Phrase.suffix = "__}}"
    end

    subject { Phrase::Delegate::FastGettext.new(method, *args).to_s }

    context "_" do
      let(:method) { :_ }
      let(:args) { "lorem ipsum" }

      it { should eql("{{__phrase_lorem ipsum__}}")}
    end

    context "n_" do
      let(:method) { :n_ }
      let(:args) { ["lorem ipsum singular", "lorem ipsum plural"] }

      it { should eql("{{__phrase_lorem ipsum singular__}}") }
    end

    context "s_" do
      let(:method) { :s_ }
      let(:args) { "lorem ipsum namespace" }

      it { should eql("{{__phrase_lorem ipsum namespace__}}")}
    end
  end

  describe "#params_from_args(method, args)" do
    let(:delegate) { Phrase::Delegate::FastGettext.new(method, *args) }
    subject { delegate.send(:params_from_args, args) }

    context "_" do
      let(:method) { :_ }
      let(:args) { ["lorem ipsum"] }

      it { should == {msgid: "lorem ipsum"} }
    end

    context "n_" do
      let(:method) { :n_ }
      let(:args) { ["lorem ipsum singular", "lorem ipsum plural", 99] }

      it { should == {msgid: "lorem ipsum singular", msgid_plural: "lorem ipsum plural", count: 99} }
    end

    context "s_" do
      let(:method) { :s_ }
      let(:args) { ["lorem|lorem ipsum namespace"] }

      it { should == {msgid: "lorem|lorem ipsum namespace"} }
    end

    context "unknown method" do
      let(:method) { :foo_ }
      let(:args) { [] }

      it { should == {} }
      specify { Phrase::Delegate::FastGettext.should_receive(:log).with(/unsupported/i); subject; }
    end
  end
end
