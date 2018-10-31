class CreateExpenses < ActiveRecord::Migration[5.1]
  def change
    create_table :expenses do |t|
      t.belongs_to :property, index: true

      t.boolean :is_cost
      t.decimal :cost, :precision => 2
      t.datetime :date
      t.string :category
      t.text :comment
      t.timestamps

      #t.index [:property_id, :date, :type, :is_cost], :unique => true
    end
  end
end
