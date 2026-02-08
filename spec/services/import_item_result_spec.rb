require 'rails_helper'

RSpec.describe ImportItemResult do
  describe "status predicates" do
    it "identifies created status" do
      result = ImportItemResult.new(status: :created, name: "Burger")
      expect(result).to be_created
      expect(result).not_to be_existing
      expect(result).not_to be_failed
    end

    it "identifies existing status" do
      result = ImportItemResult.new(status: :existing, name: "Burger")
      expect(result).to be_existing
    end

    it "identifies failed status" do
      result = ImportItemResult.new(status: :failed, name: "Burger", error: "Invalid")
      expect(result).to be_failed
      expect(result.error).to eq("Invalid")
    end
  end

  describe "invalid status" do
    it "raises ArgumentError" do
      expect { ImportItemResult.new(status: :unknown, name: "Burger") }
        .to raise_error(ArgumentError, /Invalid status/)
    end
  end

  describe "#to_h" do
    it "returns hash without error for non-failed items" do
      result = ImportItemResult.new(status: :created, name: "Burger")
      expect(result.to_h).to eq({ name: "Burger", status: :created })
    end

    it "includes error for failed items" do
      result = ImportItemResult.new(status: :failed, name: "Burger", error: "Bad data")
      expect(result.to_h).to eq({ name: "Burger", status: :failed, error: "Bad data" })
    end
  end
end
