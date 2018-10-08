class CreateExcelReports < ActiveRecord::Migration[5.1]
  def change
    create_table :excel_reports do |t|
      t.string :excel
      t.string :original_filename
      t.string :digest
      t.boolean :parsed
      t.timestamps

      t.index [:digest], :unique => true
    end
  end
end
