require "spec_helper"

describe PCO::URL::Engine::DomainMiddleware, type: :request do
  context "in development mode" do
    before do
      ENV["DEPLOY_ENV"] = Rails.env = "development"
    end

    it "sets the generated URL domain to be the same as the host" do
      host! "accounts.pco.test"
      get "/test"
      expect(response.body).to eq("http://people.pco.test")
      host! "accounts.pco.codes"
      get "/test"
      expect(response.body).to eq("http://people.pco.codes")
    end
  end

  context "in test mode" do
    before do
      ENV["DEPLOY_ENV"] = Rails.env = "test"
    end

    it "sets the generated URL domain to be the same as the host" do
      host! "accounts.pco.test"
      get "/test"
      expect(response.body).to eq("http://people.pco.test")
      host! "accounts.pco.codes"
      get "/test"
      expect(response.body).to eq("http://people.pco.test")
    end
  end

  context "in staging mode" do
    before do
      ENV["DEPLOY_ENV"] = Rails.env = "staging"
    end

    it "does not change the domain based on host" do
      host! "accounts.pco.test"
      get "/test"
      expect(response.body).to eq("https://people-staging.planningcenteronline.com")
    end
  end

  context "in production mode" do
    before do
      ENV["DEPLOY_ENV"] = Rails.env = "production"
    end

    it "does not change the domain based on host" do
      host! "accounts.pco.test"
      get "/test"
      expect(response.body).to eq("https://people.planningcenteronline.com")
    end
  end
end
