class MenuItem < ApplicationRecord
  has_many :menu_item_placements, dependent: :destroy
  has_many :menus, through: :menu_item_placements

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
