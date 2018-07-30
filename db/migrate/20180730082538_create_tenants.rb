class CreateTenants < ActiveRecord::Migration[5.1]
  def change
    create_table :tenants do |t|
      t.string :tenant_name
      t.string :tenant_phone
      t.string :tenant_email

      t.timestamps
    end
  end
end
