class CreateHousingReports < ActiveRecord::Migration[5.1]
  def change
    create_table :housing_reports do |t|
      t.string :report
      t.string :original_filename
      t.string :digest
      t.boolean :parsed
      t.string :parse_status
      t.string :parse_message
      t.timestamps

      t.index [:digest], :unique => true
    end
  end
end
