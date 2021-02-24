# frozen_string_literal: true

require "spec_helper"

describe PCO::URL::Engine::DomainMiddleware, type: :request do
  before do
    ENV["DEPLOY_ENV"] = Rails.env = "development"
  end

  context "when the host is accounts.pco.test" do
    before { host! "accounts.pco.test" }

    it "sets the generated URL domain to be the same as the host" do
      get "/test"
      expect(response.body).to eq("http://people.pco.test")
    end
  end

  context "when the host is accounts.pco.codes" do
    before { host! "accounts.pco.codes" }

    it "sets the generated URL domain to be the same as the host" do
      get "/test"
      expect(response.body).to eq("http://people.pco.codes")
    end
  end

  context "when the host is accounts.planningcenter.com" do
    before { host! "accounts.planningcenter.com" }

    it "sets the generated URL domain to be the same as the host" do
      get "/test"
      expect(response.body).to eq("http://people.planningcenter.com")
    end
  end

  context "when the host is accounts.planningcenteronline.com" do
    before { host! "accounts.planningcenteronline.com" }

    it "sets the generated URL domain to be the same as the host" do
      get "/test"
      expect(response.body).to eq("http://people.planningcenteronline.com")
    end
  end
end
