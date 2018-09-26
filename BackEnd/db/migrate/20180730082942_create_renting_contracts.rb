class CreateRentingContracts < ActiveRecord::Migration[5.1]
  def change
    create_table :renting_contracts do |t|
      t.belongs_to :user, index: true
      t.belongs_to :tenant, index: true
      t.datetime :expire_date
      t.timestamps
    end
  end
end
