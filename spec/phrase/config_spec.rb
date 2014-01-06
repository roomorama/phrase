require 'spec_helper'
require 'phrase/config'
require 'phrase/backend'

describe Phrase::Config do
  subject {
    Phrase::Config.new
  }

  after(:each) do
    Phrase::Config.class_variable_set(:@@auth_token, nil)
    Phrase::Config.class_variable_set(:@@enabled, false)
    Phrase::Config.class_variable_set(:@@backend, Phrase::Backend::PhraseService.new)
    Phrase::Config.class_variable_set(:@@prefix, "{{__")
    Phrase::Config.class_variable_set(:@@suffix, "__}}")
  end

  describe "#client_version" do
    it "should return the phrase client version" do
      subject.client_version.should == "0.1"
      Phrase::CLIENT_VERSION.should == "0.1"
    end
  end

  describe "#api_version" do
    it "should return the phrase client version" do
      subject.api_version.should == "v1"
      Phrase::API_VERSION.should == "v1"
    end
  end

  describe "#auth_token" do
    before(:each) do
      Phrase::Config.class_variable_set(:@@auth_token, nil)
    end

    context "has been set" do
      it "should return the set token" do
        subject.auth_token = "foo"
        subject.auth_token.should == "foo"
      end
    end

    context "instance variable is not set" do
      it "should return empty string" do
        subject.auth_token.should == ""
      end
    end
  end

  describe "#auth_token=" do
    it "should set the auth token" do
      subject.auth_token = "bar"
      Phrase::Config.class_variable_get(:@@auth_token).should == "bar"
    end
  end

  describe "#enabled" do
    before(:each) do
      Phrase::Config.class_variable_set(:@@enabled, nil)
    end

    context "has been set" do
      it "should return the set value" do
        subject.enabled = "maybe"
        subject.enabled.should == "maybe"
      end
    end

    context "has not been set" do
      it "should be false by default" do
        subject.enabled.should be_false
      end
    end
  end

  describe "#enabled=" do
    it "should set the enabled state" do
      subject.enabled = "maybe"
      Phrase::Config.class_variable_get(:@@enabled).should == "maybe"
    end

    it "should be able to set enabled to false" do
      subject.enabled = false
      subject.enabled.should be_false
    end
  end

  describe "#backend" do
    before(:each) do
      Phrase::Config.class_variable_set(:@@backend, nil)
    end

    context "has been set" do
      it "should return the set value" do
        subject.backend = "MyBackend"
        subject.backend.should == "MyBackend"
      end
    end

    context "has not been set" do
      it "should return an instance of PhraseService by default" do
        subject.backend.should be_a Phrase::Backend::PhraseService
      end
    end
  end

  describe "#backend=" do
    it "should set the backend" do
      subject.backend = "MyBackend"
      Phrase::Config.class_variable_get(:@@backend).should == "MyBackend"
    end
  end

  describe "#prefix" do
    before(:each) do
      Phrase::Config.class_variable_set(:@@prefix, nil)
    end

    context "has been set" do
      it "should return the set prefix" do
        subject.prefix = "##__"
        subject.prefix.should == "##__"
      end
    end

    context "instance variable is not set" do
      it "should return the default prefix" do
        subject.prefix.should == "{{__"
      end
    end
  end

  describe "#prefix=" do
    it "should set the prefix" do
      subject.prefix = "%%"
      Phrase::Config.class_variable_get(:@@prefix).should == "%%"
    end
  end

  describe "#suffix" do
    before(:each) do
      Phrase::Config.class_variable_set(:@@suffix, nil)
    end

    context "has been set" do
      it "should return the set suffix" do
        subject.suffix = "__##"
        subject.suffix.should == "__##"
      end
    end

    context "instance variable is not set" do
      it "should return the default suffix" do
        subject.suffix.should == "__}}"
      end
    end
  end

  describe "#suffix=" do
    it "should set the suffix" do
      subject.suffix = "%%"
      Phrase::Config.class_variable_get(:@@suffix).should == "%%"
    end
  end

  describe "#js_host" do
    before(:each) do
      Phrase::Config.class_variable_set(:@@js_host, nil)
    end

    context "has been set" do
      it "should return the set js_host" do
        subject.js_host = "example.com"
        subject.js_host.should == "example.com"
      end
    end

    context "instance variable is not set" do
      it "should return the default host" do
        subject.js_host.should == "phraseapp.com"
      end
    end
  end

  describe "#js_host=" do
    it "should set the js_host" do
      subject.js_host = "localhost"
      Phrase::Config.class_variable_get(:@@js_host).should == "localhost"
    end
  end

  describe "#js_use_ssl" do
    before(:each) do
      Phrase::Config.class_variable_set(:@@js_use_ssl, nil)
    end

    context "has been set" do
      it "should return the set js_host" do
        subject.js_use_ssl = "maybe"
        subject.js_use_ssl.should == "maybe"
      end
    end

    context "instance variable is not set" do
      it "should return true as default" do
        subject.js_use_ssl.should be_true
      end
    end
  end

  describe "#js_use_ssl=" do
    it "should set js_use_ssl" do
      subject.js_use_ssl = "maybe"
      Phrase::Config.class_variable_get(:@@js_use_ssl).should == "maybe"
    end
  end

  describe "#cache_key_segments_initial" do
    before(:each) do
      Phrase::Config.class_variable_set(:@@cache_key_segments_initial, nil)
    end

    context "has been set" do
      it "should return the cache_key_segments_initial" do
        subject.cache_key_segments_initial = ["foo", "bar"]
        subject.cache_key_segments_initial.should == ["foo", "bar"]
      end
    end

    context "instance variable is not set" do
      it "should return an array" do
        subject.cache_key_segments_initial.should be_an(Array)
      end
    end
  end

  describe "#cache_key_segments=" do
    it "should set the cache_key_segments_initial" do
      subject.cache_key_segments_initial = ["foo"]
      Phrase::Config.class_variable_get(:@@cache_key_segments_initial).should == ["foo"]
    end
  end

  describe "#cache_lifetime" do
    before(:each) do
      Phrase::Config.class_variable_set(:@@cache_lifetime, nil)
    end

    context "has been set" do
      it "should return the cache_lifetime" do
        subject.cache_lifetime = 99
        subject.cache_lifetime.should == 99
      end
    end

    context "instance variable is not set" do
      it "should return 5 minutes" do
        subject.cache_lifetime.should eql 300
      end
    end
  end

  describe "#cache_lifetime=" do
    it "should set the cache_lifetime" do
      subject.cache_lifetime = 77
      Phrase::Config.class_variable_get(:@@cache_lifetime).should == 77
    end
  end

  describe "#ignored_keys" do
    before(:each) do
      Phrase::Config.class_variable_set(:@@ignored_keys, nil)
    end

    context "has been set" do
      it "should return the cache_lifetime" do
        subject.ignored_keys = ["foo"]
        subject.ignored_keys.should == ["foo"]
      end
    end

    context "instance variable is not set" do
      specify { subject.ignored_keys.should eql [] }
    end
  end

  describe "#ignored_keys=" do
    it "should set the list of ignored_keys" do
      subject.ignored_keys = ["foo"]
      Phrase::Config.class_variable_get(:@@ignored_keys).should == ["foo"]
    end
  end
end
