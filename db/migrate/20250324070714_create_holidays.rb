class CreateHolidays < ActiveRecord::Migration[8.0]
  def change
    create_table :holidays do |t|
      t.date :date, null: false
      t.string :name, null: false
      t.boolean :is_bank_holiday, default: false
      t.boolean :is_exception, default: false
      t.text :description

      t.timestamps
    end

    add_index :holidays, :date, unique: true
    add_index :holidays, :is_bank_holiday
    add_index :holidays, :is_exception
  end
end
