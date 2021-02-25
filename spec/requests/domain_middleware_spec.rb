# frozen_string_literal: true

require "spec_helper"

describe PCO::URL::Engine::DomainMiddleware, type: :request do
  context "in development" do
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

  context "in staging" do
    before do
      ENV["DEPLOY_ENV"] = Rails.env = "staging"
    end

    it "sets the generated URL domain to be the same as the host" do
      host! "accounts-staging.planningcenteronline.com"
      get "/test"
      expect(response.body).to eq("https://people-staging.planningcenteronline.com")

      host! "accounts-staging.planningcenter.com"
      get "/test"
      expect(response.body).to eq("https://people-staging.planningcenter.com")
    end
  end

  context "in production" do
    before do
      ENV["DEPLOY_ENV"] = Rails.env = "production"
    end

    it "sets the generated URL domain to be the same as the host" do
      host! "accounts.planningcenteronline.com"
      get "/test"
      expect(response.body).to eq("https://people.planningcenteronline.com")

      host! "accounts.planningcenter.com"
      get "/test"
      expect(response.body).to eq("https://people.planningcenter.com")
    end

    context "when the host is something unrecognized" do
      before { host! "accounts.evilplanningcenter.com" }

      it "sets the generated URL domain to be .planningcenteronline.com" do
        get "/test"
        expect(response.body).to eq("https://people.planningcenteronline.com")
      end
    end
  end
end
