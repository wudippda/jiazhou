class CreateEmailJobHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :email_job_histories do |t|
      t.datetime :execution_time
      t.integer :status
      t.timestamps
    end
  end
end
