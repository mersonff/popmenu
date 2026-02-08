require 'rails_helper'

RSpec.describe MenuItem, type: :model do
  describe "associations" do
    it { should have_many(:menu_item_placements).dependent(:destroy) }
    it { should have_many(:menus).through(:menu_item_placements) }
  end

  describe "validations" do
    subject { create(:menu_item) }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
  end
end
