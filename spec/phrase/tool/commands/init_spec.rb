require "spec_helper"

describe Phrase::Tool::Commands::Init do
  let(:args) { [] }
  let(:options) { Phrase::Tool::Options.new(args, "init") }
  let(:api_client) { stub }

  subject { Phrase::Tool::Commands::Init.new(options, args) }

  before(:each) do
    Phrase::Tool::Commands::Init.any_instance.stub(:print_error)
    Phrase::Tool::Commands::Init.any_instance.stub(:print_server_error)
    Phrase::Tool::Commands::Init.any_instance.stub(:print_message)
    subject.stub(:print_message)
    subject.stub(:print_error)
    subject.stub(:exit_command)
  end

  describe "#execute!" do
    before(:each) do
      subject.stub(:api_client).and_return(api_client)
      subject.stub(:create_locale)
      subject.stub(:make_locale_default)
    end

    context "secret was given" do
      let(:args) { ["--secret=secr3t", "--default-locale=fooish"] }

      it "should store the secret in config object" do
        subject.execute!
        subject.send(:config).secret.should eql("secr3t")
      end

      it "should display a success message" do
        subject.should_receive(:print_message).with(/wrote secret to config file/i)
        subject.execute!
      end

      it "should try to create the default locale" do
        subject.should_receive(:create_locale).with("fooish")
        subject.execute!
      end

      it "should try to make the default locale default for this account" do
        subject.should_receive(:make_locale_default).with("fooish")
        subject.execute!
      end
    end

    context "no secret was given" do
      let(:args) { [] }

      it "should display an error" do
        subject.should_receive(:print_error).with(/No auth token was given/)
        subject.execute!
      end

      it "should exit" do
        subject.should_receive(:exit_command)
        subject.execute!
      end
    end
  end

  describe "#create_locale" do
    let(:api_client) { stub(create_locale: "") }

    before(:each) do
      subject.stub(:api_client).and_return(api_client)
    end

    it "should create a locale" do
      api_client.should_receive(:create_locale).with("foo")
      subject.send(:create_locale, "foo")
    end

    describe "when locale can be created" do
      it "should display a success message" do
        subject.should_receive(:print_message).with(/created locale/i)
        subject.send(:create_locale, "foo")
      end
    end

    describe "when locale cannot be created" do
      before(:each) do
        api_client.stub(:create_locale).and_raise("Some server error")
      end

      it "should display a warning" do
        subject.should_receive(:print_message).with(/could not be created/i)
        subject.send(:create_locale, "foo")
      end
    end
  end

  describe "#make_locale_default" do
    let(:api_client) { stub(make_locale_default: "") }

    before(:each) do
      subject.stub(:api_client).and_return(api_client)
    end

    it "should make a locale the default locale" do
      api_client.should_receive(:make_locale_default).with("foo")
      subject.send(:make_locale_default, "foo")
    end

    describe "when locale can be made the default locale" do
      it "should display a success message" do
        subject.should_receive(:print_message).with(/is now the default locale/i)
        subject.send(:make_locale_default, "foo")
      end
    end

    describe "when locale cannot be created" do
      before(:each) do
        api_client.stub(:make_locale_default).and_raise("Some server error")
      end

      it "should display a warning" do
        subject.should_receive(:print_message).with(/could not be made the default locale/i)
        subject.send(:make_locale_default, "foo")
      end
    end
  end
end
