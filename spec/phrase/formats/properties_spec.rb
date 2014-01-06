require 'spec_helper'

describe Phrase::Formats::Properties do
  let(:the_current_directory) { "./" }
  let(:the_prefix) { "phrase" }
  let(:the_locale_name) { "fooish" }
  let(:the_locale) { Phrase::Tool::Locale.new(name: the_locale_name) }
  let(:the_extension) { ".properties" }

  describe "#self.directory_for_locale" do
    it "should return the path to the current dir" do
      Phrase::Formats::Properties.directory_for_locale(the_locale).should eql(the_current_directory)
    end
  end

  describe "#self.filename_for_locale" do
    subject { Phrase::Formats::Properties.filename_for_locale(the_locale) }

    it { should include the_prefix }
    it { should include the_locale_name }
    it { should end_with the_extension }
  end

  describe "#self.locale_aware?" do
    subject { Phrase::Formats::Properties.locale_aware? }

    it { should be_true }
  end
end
