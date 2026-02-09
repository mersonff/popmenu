class CreateImports < ActiveRecord::Migration[8.0]
  def change
    create_table :imports do |t|
      t.string :status, null: false, default: "pending"
      t.json :input_data, null: false
      t.json :result_data
      t.string :error_message
      t.timestamps
    end
  end
end
