require 'rails_helper'

RSpec.describe JsonImportService do
  let(:logger) { instance_double(Logger, info: nil, warn: nil) }

  def import(data)
    JsonImportService.new(data: data, logger: logger).call
  end

  describe "valid import" do
    let(:data) { JSON.parse(file_fixture("valid_import.json").read) }

    it "returns a successful result" do
      result = import(data)

      expect(result).to be_success
    end

    it "creates restaurants" do
      expect { import(data) }.to change(Restaurant, :count).by(1)
    end

    it "creates menus" do
      expect { import(data) }.to change(Menu, :count).by(2)
    end

    it "creates unique menu items" do
      expect { import(data) }.to change(MenuItem, :count).by(3) # Burger, Salad, Steak
    end

    it "creates placements including shared items" do
      expect { import(data) }.to change(MenuItemPlacement, :count).by(4)
    end

    it "returns correct summary" do
      result = import(data)

      expect(result.data[:restaurants_created]).to eq(1)
      expect(result.data[:total]).to eq(4)
      expect(result.data[:created]).to eq(3)
      expect(result.data[:existing]).to eq(1) # Burger on Dinner
      expect(result.data[:failed]).to eq(0)
    end

    it "logs each item result" do
      import(data)

      expect(logger).to have_received(:info).with("Created item: Burger")
      expect(logger).to have_received(:info).with("Created item: Salad")
      expect(logger).to have_received(:info).with("Created item: Steak")
      expect(logger).to have_received(:info).with("Existing item: Burger")
    end
  end

  describe "partial failure" do
    let(:data) { JSON.parse(file_fixture("invalid_import.json").read) }

    it "continues after individual item failures" do
      result = import(data)

      expect(result).to be_success
      expect(result.data[:total]).to eq(2)
      expect(result.data[:created]).to eq(1)
      expect(result.data[:failed]).to eq(1)
    end

    it "logs the failure" do
      import(data)

      expect(logger).to have_received(:warn).with(/Failed to import item/)
    end
  end

  describe "malformed data" do
    let(:data) { JSON.parse(file_fixture("malformed_import.json").read) }

    it "returns a failure result" do
      result = import(data)

      expect(result).to be_failure
      expect(result.error).to match(/Invalid data/)
    end
  end

  describe "idempotency" do
    let(:data) { JSON.parse(file_fixture("valid_import.json").read) }

    it "does not duplicate items on second import" do
      import(data)

      expect { import(data) }.not_to change(MenuItem, :count)
    end

    it "marks all items as existing on second import" do
      import(data)
      result = import(data)

      expect(result.data[:existing]).to eq(4)
      expect(result.data[:created]).to eq(0)
    end
  end
end
