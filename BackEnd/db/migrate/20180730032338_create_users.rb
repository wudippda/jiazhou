class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :phone_number
      t.timestamps

      t.index [:email], :unique => true
    end
  end
end
