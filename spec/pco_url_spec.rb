require "spec_helper"

describe PCO::URL do
  describe "defaults" do
    describe "development" do
      before do
        Rails.env = "development"
      end

      PCO::URL.applications.map(&:to_s).each do |app|
        it "has an #{app} URL" do
          expect(PCO::URL.send(app)).to eq("http://#{app.gsub('_','-')}.pco.dev")
        end
      end
    end

    describe "staging" do
      before do
        Rails.env = "staging"
      end

      PCO::URL.applications.map(&:to_s).each do |app|
        it "has an #{app} URL" do
          expect(PCO::URL.send(app)).to eq("https://#{app.gsub('_','-')}-staging.planningcenteronline.com")
        end
      end
    end

    describe "production" do
      before do
        Rails.env = "production"
      end

      PCO::URL.applications.map(&:to_s).each do |app|
        it "has an #{app} URL" do
          expect(PCO::URL.send(app)).to eq("https://#{app.gsub('_','-')}.planningcenteronline.com")
        end
      end
    end

    describe "test" do
      before do
        Rails.env = "test"
      end

      PCO::URL.applications.map(&:to_s).each do |app|
        it "has an #{app} URL" do
          expect(PCO::URL.send(app)).to eq("http://#{app.gsub('_','-')}.pco.test")
        end
      end
    end
  end

  describe "overrides" do
    describe "development with accounts URL override" do
      before do
        Rails.env = "development"
        ENV["ACCOUNTS_URL"] = "http://bazinga.com"
      end

      it "has a custom accounts URL" do
        expect(PCO::URL.accounts).to eq("http://bazinga.com")
      end
    end

    describe "Rails.env staging with DEPLOY_ENV override" do
      before do
        Rails.env = "development"
        ENV["ACCOUNTS_URL"] = nil
        ENV["DEPLOY_ENV"] = "staging"
      end

      it "loads the DEPLOY_ENV URLs" do
        expect(PCO::URL.accounts).to eq("https://accounts-staging.planningcenteronline.com")
      end
    end

    describe "Rails.env staging with DEPLOY_ENV override and ACCOUNTS_URL override" do
      before do
        Rails.env = "development"
        ENV["ACCOUNTS_URL"] = "http://accounts-test1.planningcenteronline.com"
        ENV["DEPLOY_ENV"] = "staging"
      end

      it "loads the DEPLOY_ENV URLs" do
        expect(PCO::URL.accounts).to eq("http://accounts-test1.planningcenteronline.com")
      end
    end
  end

  describe "custom applications" do
    before do
      Rails.env = "development"
      ENV["DEPLOY_ENV"] = nil
    end

    describe "adding an app" do
      it "adds a URL method for bazinga" do
        PCO::URL.applications += [:bazinga]
        expect(PCO::URL.bazinga).to eq("http://bazinga.pco.dev")
      end
    end

    describe "removing an app" do
      it "removes the URL method for accounts" do
        PCO::URL.applications -= [:accounts]
        expect{PCO::URL.accounts}.to raise_error(NoMethodError)
      end
    end
  end
end
