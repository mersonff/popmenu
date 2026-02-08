require 'rails_helper'

RSpec.describe "Imports", type: :request do
  let(:restaurant) { create(:restaurant) }

  describe "POST /restaurants/:restaurant_id/import" do
    it "imports valid data" do
      data = JSON.parse(file_fixture("valid_import.json").read)

      post "/restaurants/#{restaurant.id}/import", params: data, as: :json

      expect(response).to have_http_status(:ok)
      expect(parsed_body["data"]["total"]).to eq(4)
      expect(parsed_body["data"]["created"]).to eq(3)
      expect(parsed_body["data"]["existing"]).to eq(1)
      expect(parsed_body["data"]["failed"]).to eq(0)
    end

    it "handles partial failures" do
      data = JSON.parse(file_fixture("invalid_import.json").read)

      post "/restaurants/#{restaurant.id}/import", params: data, as: :json

      expect(response).to have_http_status(:ok)
      expect(parsed_body["data"]["failed"]).to eq(1)
      expect(parsed_body["data"]["created"]).to eq(1)
    end

    it "returns 422 for malformed data" do
      data = JSON.parse(file_fixture("malformed_import.json").read)

      post "/restaurants/#{restaurant.id}/import", params: data, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_body["error"]["message"]).to match(/Invalid data/)
    end

    it "returns 404 for non-existent restaurant" do
      post "/restaurants/999/import", params: { menus: [] }, as: :json

      expect(response).to have_http_status(:not_found)
    end

    it "is idempotent" do
      data = JSON.parse(file_fixture("valid_import.json").read)

      post "/restaurants/#{restaurant.id}/import", params: data, as: :json
      post "/restaurants/#{restaurant.id}/import", params: data, as: :json

      expect(response).to have_http_status(:ok)
      expect(parsed_body["data"]["created"]).to eq(0)
      expect(parsed_body["data"]["existing"]).to eq(4)
    end
  end

  private

  def parsed_body
    JSON.parse(response.body)
  end
end
