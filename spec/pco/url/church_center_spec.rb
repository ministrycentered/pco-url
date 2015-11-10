require "spec_helper"

describe PCO::URL::ChurchCenter do
  context "when the env is production" do
    before do
      Rails.env = "production"
    end

    describe "#to_s" do
      context "given a subdomain" do
        subject { described_class.new(subdomain: "foo") }

        it "returns the proper URL" do
          expect(subject.to_s).to eq("https://foo.churchcenteronline.com")
        end
      end
    end
  end

  context "when the env is staging" do
    before do
      Rails.env = "staging"
    end

    describe "#to_s" do
      context "given a subdomain" do
        subject { described_class.new(subdomain: "foo") }

        it "returns the proper URL" do
          expect(subject.to_s).to eq("https://foo.staging.churchcenteronline.com")
        end
      end
    end
  end

  context "when the env is development" do
    before do
      Rails.env = "development"
    end

    describe "#to_s" do
      context "given a subdomain" do
        subject { described_class.new(subdomain: "foo") }

        it "returns the proper URL" do
          expect(subject.to_s).to eq("http://foo.churchcenter.dev")
        end
      end
    end
  end
end
