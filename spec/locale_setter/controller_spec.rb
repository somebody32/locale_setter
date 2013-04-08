require 'spec_helper'

describe LocaleSetter::Controller do
  it "exists" do
    expect{ LocaleSetter::Controller }.to_not raise_error
  end

  class BareController
    def self.prepend_before_filter(name); end

    def params; @params ||= {}; end
    def params=(hash); @params = hash; end
  end

  describe ".included" do
    it "prepending a before filter" do
      BareController.should_receive(:prepend_before_filter).with(:set_locale)
      BareController.send(:include, LocaleSetter::Controller)
    end

    it "skips prepending the before_filter if not supported" do
      expect{ BareController.send(:include, LocaleSetter::Controller) }.to_not raise_error
    end
  end

  class Controller < BareController
    include LocaleSetter::Controller
  end

  let(:controller){ Controller.new }

  before(:each) do
    controller.i18n.locale = :es
  end

  describe "#default_url_options" do
    it "adds a :locale key if it presents in params" do
      controller.params = { :locale => :de }
      expect { controller.default_url_options({})[:locale] }.to be
    end

    it "dosn't adds a :locale key if no params present" do
      controller.params = {}
      expect { controller.default_url_options({})[:locale] }.not_to be
    end

    it "does not require a parameter" do
      expect { controller.default_url_options }.to_not raise_error
    end

    it "builds on passed in options" do
      result = controller.default_url_options({:test => true})
      result[:test].should be
      result[:locale].should be
    end

    it "defers to a passed in locale" do
      result = controller.default_url_options({:locale => 'abc'})
      result[:locale].should == 'abc'
    end

    it "doesn't appent a locale if it's the default" do
      controller.i18n.locale = controller.i18n.default_locale
      controller.default_url_options({})[:locale].should_not be
    end

    it "appends a locale when not the default" do
      controller.i18n.locale = :sample
      controller.default_url_options({})[:locale].should == :sample
    end
  end
end