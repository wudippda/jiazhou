class CreateExpenses < ActiveRecord::Migration[5.1]
  def change
    create_table :expenses do |t|
      t.boolean :is_cost
      t.string :date
      t.string :type
      t.text :comment
      t.belongs_to :property, index: true
      t.timestamps
    end
  end
end
