require "spec_helper"

Applications = [
  :accounts,
  :avatars,
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
    URLcrypt.key = "984e9002e680dc9b9c2556434c47f7e4782191f52063277901e4a009797652e08f28be069dfb4d4a1e3c9ab09fedab59be2c9b6486748bf44030182815ee4987"
  end

  describe "defaults" do
    describe "development" do
      before do
        Rails.env = "development"
      end

      Applications.map(&:to_s).each do |app|
        it "has an #{app} URL" do
          expect(PCO::URL.send(app)).to eq("http://#{app.gsub('_','-')}.pco.dev")
        end
      end

      it "has a church-center url" do
        expect(PCO::URL.church_center).to eq("http://churchcenter.dev")
      end
    end

    describe "staging" do
      before do
        Rails.env = "staging"
      end

      Applications.map(&:to_s).each do |app|
        next if app == "get"
        it "has an #{app} URL" do
          expect(PCO::URL.send(app)).to eq("https://#{app.gsub('_','-')}-staging.planningcenteronline.com")
        end
      end

      it "has an http get URL" do
        expect(PCO::URL.send("get")).to eq("http://get-staging.planningcenteronline.com")
      end

      it "has a church-center url" do
        expect(PCO::URL.church_center).to eq("https://staging.churchcenteronline.com")
      end
    end

    describe "production" do
      before do
        Rails.env = "production"
      end

      Applications.map(&:to_s).each do |app|
        next if app == "get"
        it "has an #{app} URL" do
          expect(PCO::URL.send(app)).to eq("https://#{app.gsub('_','-')}.planningcenteronline.com")
        end
      end

      it "has an http get URL" do
        expect(PCO::URL.send("get")).to eq("http://get.planningcenteronline.com")
      end

      it "has a church-center url" do
        expect(PCO::URL.church_center).to eq("https://churchcenteronline.com")
      end
    end

    describe "test" do
      before do
        Rails.env = "test"
      end

      Applications.map(&:to_s).each do |app|
        it "has an #{app} URL" do
          expect(PCO::URL.send(app)).to eq("http://#{app.gsub('_','-')}.pco.test")
        end
      end

      it "has a church-center url" do
        expect(PCO::URL.church_center).to eq("http://churchcenter.test")
      end
    end
  end

  describe "custom domains" do
    it "returns a URL with a custom domain" do
      expect(PCO::URL.new(app_name: "us-east", domain: "pcocdn.com").to_s).to eq("http://us-east.pcocdn.com")
    end
  end

  context "with path starting with /" do
    Applications.map(&:to_s).each do |app|
      it "has an #{app} URL with path" do
        expect(PCO::URL.send(app, "/test")).to eq("http://#{app.gsub('_','-')}.pco.test/test")
      end
    end
  end

  context "with path NOT starting with /" do
    Applications.map(&:to_s).each do |app|
      it "has an #{app} URL with path" do
        expect(PCO::URL.send(app, "test")).to eq("http://#{app.gsub('_','-')}.pco.test/test")
      end
    end
  end

  context "with multiple path arguments" do
    Applications.map(&:to_s).each do |app|
      it "has an #{app} URL with path" do
        expect(PCO::URL.send(app, "test", "test2")).to eq("http://#{app.gsub('_','-')}.pco.test/test/test2")
        expect(PCO::URL.send(app, "test/", "test2")).to eq("http://#{app.gsub('_','-')}.pco.test/test/test2")
        expect(PCO::URL.send(app, "test", "/test2")).to eq("http://#{app.gsub('_','-')}.pco.test/test/test2")
        expect(PCO::URL.send(app, "/test/", "test2")).to eq("http://#{app.gsub('_','-')}.pco.test/test/test2")
        expect(PCO::URL.send(app, "/test/test2")).to eq("http://#{app.gsub('_','-')}.pco.test/test/test2")
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

    it 'puts the encrypted params into the _e key' do
      expect(subject.query).to match(/^_e=(.*)/)
    end

    it "encrypts and decrypts URL parameters" do
      expect(URLcrypt.decrypt(subject.query.gsub("_e=", ""))).to eq("foo=bar")
    end

    it "decrypts using #decrypt_query_params" do
      expect(PCO::URL.decrypt_query_params(subject.query.gsub("_e=", ""))).to eq("foo=bar")
    end
  end

  describe '.parse' do
    subject { PCO::URL.parse("https://people-staging.planningcenteronline.com") }

    it 'returns a PCO::URL object' do
      expect(subject.class).to eq(PCO::URL)
    end

    context 'when only a url string is passed' do
      subject { PCO::URL.parse("http://people.pco.dev") }

      it 'sets the app_name attr' do
        expect(subject.app_name).to eq('people')
      end

      it 'strips -staging if supplied' do
        expect(PCO::URL.parse("https://people-staging.plannincenteronline.com").app_name).
          to eq('people')
      end
    end

    context 'when a string and path is passed' do
      subject { PCO::URL.parse("https://people.planningcenteronline.com/households/2.json") }

      it 'sets the app_name and path attrs' do
        expect(subject.app_name).to eq('people')
        expect(subject.path).to eq('households/2.json')
      end
    end

    context 'when a string, path and query are passed' do
      let(:pco_url) { PCO::URL.new(app_name: :people, path: 'households/2.html', query: 'full_access=1&total_control=1', encrypt_query_params: true) }

      subject { PCO::URL.parse("https://people.planningcenteronline.com/households/2.html?full_access=1&total_control=1") }

      it 'sets the app_name, path, and query attrs' do
        expect(subject.app_name).to eq('people')
        expect(subject.path).to eq('households/2.html')
        expect(subject.query).to eq('full_access=1&total_control=1')
      end

      context 'when the query is encrypted' do
        subject { PCO::URL.parse(pco_url.to_s) }

        it 'first decrypts the query' do
          expect(pco_url.query).not_to eq('full_access=1&total_control=1')
          expect(subject.query).to eq('full_access=1&total_control=1')
        end
      end

      context "when part of the query string is encrypted" do
        subject { PCO::URL.parse(pco_url.to_s + "&foo=bar") }

        it "decrypts the encrypted portion and appends the unencrypted portion" do
          expect(subject.query).to eq('full_access=1&total_control=1&foo=bar')
        end

        it "returns the full url" do
          expect(subject.to_s).to eq('https://people-staging.planningcenteronline.com/households/2.html?full_access=1&total_control=1&foo=bar')
        end
      end
    end
  end

end
