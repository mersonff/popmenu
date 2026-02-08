require 'rails_helper'

RSpec.describe Result do
  describe ".success" do
    it "creates a successful result" do
      result = Result.success({ total: 5 })

      expect(result).to be_success
      expect(result).not_to be_failure
      expect(result.data).to eq({ total: 5 })
      expect(result.error).to be_nil
    end

    it "works without data" do
      result = Result.success

      expect(result).to be_success
      expect(result.data).to be_nil
    end
  end

  describe ".failure" do
    it "creates a failed result" do
      result = Result.failure("Something went wrong")

      expect(result).to be_failure
      expect(result).not_to be_success
      expect(result.error).to eq("Something went wrong")
      expect(result.data).to be_nil
    end
  end
end
