class CreateMenus < ActiveRecord::Migration[8.0]
  def change
    create_table :menus do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end
