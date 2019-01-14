require "spec_helper"

APPLICATIONS = [
  :accounts,
  :services,
  :check_ins,
  :people,
  :registrations,
  :resources,
  :giving,
  :get
]

describe PCO::URL do
  before :all do
    PCO::URL::Encryption.default_key =
      "\xF7\xFE\x99I\x1EkO\xD4\xD3\v\x96\x8A\b\x17\xD8m\x01jr\x8F\xA0L.\xB3\xF3\x12\xD7c\x16\xA8\xD0."
  end

  after :all do
    reset_encryption_default_key
  end

  describe "defaults" do
    describe "development" do
      before do
        Rails.env = "development"
      end

      APPLICATIONS.map(&:to_s).each do |app|
        it "has an #{app} URL" do
          expect(PCO::URL.send(app)).to eq("http://#{app.tr('_', '-')}.pco.test")
        end
      end

      it "has a church-center url" do
        expect(PCO::URL.church_center).to eq("http://churchcenter.test")
      end

      it "has an avatars url" do
        expect(PCO::URL.avatars).to eq("http://avatars.pco.test")
      end
    end

    describe "staging" do
      before do
        Rails.env = "staging"
      end

      APPLICATIONS.map(&:to_s).each do |app|
        next if app == "get"
        it "has an #{app} URL" do
          expect(PCO::URL.send(app)).to eq("https://#{app.tr('_', '-')}-staging.planningcenteronline.com")
        end
      end

      it "has an http get URL" do
        expect(PCO::URL.send("get")).to eq("http://get-staging.planningcenteronline.com")
      end

      it "has a church-center url" do
        expect(PCO::URL.church_center).to eq("https://staging.churchcenter.com")
      end

      it "uses production for avatars because staging does not exist" do
        expect(PCO::URL.avatars).to eq("https://avatars.planningcenteronline.com")
      end
    end

    describe "production" do
      before do
        Rails.env = "production"
      end

      APPLICATIONS.map(&:to_s).each do |app|
        next if app == "get"
        it "has an #{app} URL" do
          expect(PCO::URL.send(app)).to eq("https://#{app.tr('_', '-')}.planningcenteronline.com")
        end
      end

      it "has an http get URL" do
        expect(PCO::URL.send("get")).to eq("http://get.planningcenteronline.com")
      end

      it "has a church-center url" do
        expect(PCO::URL.church_center).to eq("https://churchcenter.com")
      end

      it "has an avatars url" do
        expect(PCO::URL.avatars).to eq("https://avatars.planningcenteronline.com")
      end
    end

    describe "test" do
      before do
        Rails.env = "test"
      end

      APPLICATIONS.map(&:to_s).each do |app|
        it "has an #{app} URL" do
          expect(PCO::URL.send(app)).to eq("http://#{app.tr('_', '-')}.pco.test")
        end
      end

      it "has a church-center url" do
        expect(PCO::URL.church_center).to eq("http://churchcenter.test")
      end

      it "has an avatars url" do
        expect(PCO::URL.avatars).to eq("http://avatars.pco.test")
      end
    end
  end

  describe "custom domains" do
    it "returns a URL with a custom domain" do
      expect(PCO::URL.new(app_name: "us-east", domain: "pcocdn.com").to_s).to eq("http://us-east.pcocdn.com")
    end
  end

  context "with path starting with /" do
    APPLICATIONS.map(&:to_s).each do |app|
      it "has an #{app} URL with path" do
        expect(PCO::URL.send(app, "/test")).to eq("http://#{app.tr('_', '-')}.pco.test/test")
      end
    end
  end

  context "with path NOT starting with /" do
    APPLICATIONS.map(&:to_s).each do |app|
      it "has an #{app} URL with path" do
        expect(PCO::URL.send(app, "test")).to eq("http://#{app.tr('_', '-')}.pco.test/test")
      end
    end
  end

  context "with multiple path arguments" do
    APPLICATIONS.map(&:to_s).each do |app|
      it "has an #{app} URL with path" do
        expect(PCO::URL.send(app, "test", "test2")).to   eq("http://#{app.tr('_', '-')}.pco.test/test/test2")
        expect(PCO::URL.send(app, "test/", "test2")).to  eq("http://#{app.tr('_', '-')}.pco.test/test/test2")
        expect(PCO::URL.send(app, "test", "/test2")).to  eq("http://#{app.tr('_', '-')}.pco.test/test/test2")
        expect(PCO::URL.send(app, "/test/", "test2")).to eq("http://#{app.tr('_', '-')}.pco.test/test/test2")
        expect(PCO::URL.send(app, "/test/test2")).to     eq("http://#{app.tr('_', '-')}.pco.test/test/test2")
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

  describe "encrypted params" do
    subject { PCO::URL.new(app_name: "people", query: "foo=bar", encrypt_query_params: true) }

    it "encrypts URL parameters" do
      expect(subject.query).to_not eq("foo=bar")
    end

    it "puts the encrypted params into the _e key" do
      expect(subject.query).to match(/^_e=(.*)/)
    end

    it "encrypts and decrypts URL parameters" do
      expect(PCO::URL::Encryption.decrypt(subject.query.gsub("_e=", ""))).to eq("foo=bar")
    end

    it "decrypts using #decrypt_query_params" do
      expect(PCO::URL.decrypt_query_params(subject.query.gsub("_e=", ""))).to eq("foo=bar")
    end
  end

  describe ".parse" do
    subject { PCO::URL.parse("https://people-staging.planningcenteronline.com") }

    it "returns a PCO::URL object" do
      expect(subject.class).to eq(PCO::URL)
    end

    context "when only a url string is passed" do
      subject { PCO::URL.parse("http://people.pco.test") }

      it "sets the app_name attr" do
        expect(subject.app_name).to eq("people")
      end

      it "strips -staging if supplied" do
        expect(PCO::URL.parse("https://people-staging.plannincenteronline.com").app_name).to eq("people")
      end
    end

    context "when a string and path is passed" do
      subject { PCO::URL.parse("https://people.planningcenteronline.com/households/2.json") }

      it "sets the app_name and path attrs" do
        expect(subject.app_name).to eq("people")
        expect(subject.path).to eq("households/2.json")
      end
    end

    context "when a string, path and query are passed" do
      let(:pco_url) do
        PCO::URL.new(
          app_name: :people,
          path: "households/2.html",
          query: "full_access=1&total_control=1",
          encrypt_query_params: true
        )
      end

      subject do
        PCO::URL.parse(
          "https://people.planningcenteronline.com/households/2.html?full_access=1&total_control=1"
        )
      end

      it "sets the app_name, path, and query attrs" do
        expect(subject.app_name).to eq("people")
        expect(subject.path).to eq("households/2.html")
        expect(subject.query).to eq("full_access=1&total_control=1")
      end

      context "when the query is encrypted" do
        subject { PCO::URL.parse(pco_url.to_s) }

        it "first decrypts the query" do
          expect(pco_url.query).not_to eq("full_access=1&total_control=1")
          expect(subject.query).to eq("full_access=1&total_control=1")
        end
      end

      context "when part of the query string is encrypted" do
        subject { PCO::URL.parse(pco_url.to_s + "&foo=bar") }

        it "decrypts the encrypted portion and appends the unencrypted portion" do
          expect(subject.query).to eq("full_access=1&total_control=1&foo=bar")
        end

        it "returns the full url" do
          expect(subject.to_s).to eq(
            "https://people-staging.planningcenteronline.com/households/2.html?full_access=1&total_control=1&foo=bar"
          )
        end
      end

      context "when the encrypted part of the query string is not first" do
        let(:url) { pco_url.to_s.sub(/\?(_e=.+)/, "?foo=bar&\\1") }

        subject { PCO::URL.parse(url) }

        it "decrypts the encrypted portion and includes the unencrypted portion" do
          expect(subject.query).to eq("foo=bar&full_access=1&total_control=1")
        end

        it "returns the full url" do
          expect(subject.to_s).to eq(
            "https://people-staging.planningcenteronline.com/households/2.html?foo=bar&full_access=1&total_control=1"
          )
        end
      end
    end
  end
end
