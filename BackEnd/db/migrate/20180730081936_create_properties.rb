class CreateProperties < ActiveRecord::Migration[5.1]
  def change
    create_table :properties do |t|
      t.belongs_to :user, index: true
      #t.belongs_to :renting_contract, index: true
      #t.integer :user_id
      t.string :address
      t.string :lot
      t.timestamps
    end
  end
end
