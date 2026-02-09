require 'rails_helper'

RSpec.describe Menu, type: :model do
  describe "associations" do
    it { should belong_to(:restaurant) }
    it { should have_many(:menu_item_placements).dependent(:destroy) }
    it { should have_many(:menu_items).through(:menu_item_placements) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
  end

  describe "defaults" do
    it "defaults active to true" do
      menu = Menu.new
      expect(menu.active).to be true
    end
  end

  describe ".active" do
    it "returns only active menus" do
      restaurant = create(:restaurant)
      active_menu = create(:menu, active: true, restaurant: restaurant)
      create(:menu, active: false, restaurant: restaurant)

      expect(Menu.active).to eq([ active_menu ])
    end
  end

  describe "dependent destroy" do
    it "destroys associated placements" do
      menu = create(:menu)
      create(:menu_item_placement, menu: menu)

      expect { menu.destroy }.to change(MenuItemPlacement, :count).by(-1)
    end
  end
end
