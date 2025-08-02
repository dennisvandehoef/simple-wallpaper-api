require "rails_helper"
require "net/http"

RSpec.describe OpenMeteoService do
  before { Rails.cache.clear }

  describe ".fetch" do
    let(:url_response_body) { { "foo" => "bar" }.to_json }

    context "when the request succeeds" do
      before do
        success_resp = Net::HTTPSuccess.new("1.1", "200", "OK")
        success_resp.instance_variable_set(:@body, url_response_body)
        success_resp.instance_variable_set(:@read, true)
        allow(Net::HTTP).to receive(:get_response).and_return(success_resp)
      end

      it "returns parsed JSON" do
        result = described_class.fetch(expires_in: 0)
        expect(result).to eq({ "foo" => "bar" })
      end
    end

    context "when the request fails" do
      before do
        fail_resp = Net::HTTPInternalServerError.new("1.1", "500", "Error")
        fail_resp.instance_variable_set(:@body, "boom")
        fail_resp.instance_variable_set(:@read, true)
        allow(Net::HTTP).to receive(:get_response).and_return(fail_resp)
      end

      it "raises an error" do
        expect(Rails.logger).to receive(:error).with(/OpenMeteoService error:/)
        expect {
          described_class.fetch(expires_in: 0)
        }.to raise_error(/Open-Meteo API error/)
      end
    end
  end
end
