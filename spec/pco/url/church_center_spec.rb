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
          expect(subject.to_s).to eq("https://foo.churchcenter.com")
        end
      end

      context "given no subdomain" do
        subject { described_class.new }

        it "returns the proper URL" do
          expect(subject.to_s).to eq("https://churchcenter.com")
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
          expect(subject.to_s).to eq("https://foo.staging.churchcenter.com")
        end
      end

      context "given no subdomain" do
        subject { described_class.new }

        it "returns the proper URL" do
          expect(subject.to_s).to eq("https://staging.churchcenter.com")
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
          expect(subject.to_s).to eq("http://foo.churchcenter.test")
        end
      end

      context "given no subdomain" do
        subject { described_class.new }

        it "returns the proper URL" do
          expect(subject.to_s).to eq("http://churchcenter.test")
        end
      end
    end
  end
end
