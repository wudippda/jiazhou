class CreateRentingContracts < ActiveRecord::Migration[5.1]
  def change
    create_table :renting_contracts do |t|
      t.string :expire_date

      t.timestamps
    end
  end
end
