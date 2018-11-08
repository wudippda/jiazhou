class CreateEmailJobHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :email_job_histories do |t|
      t.belongs_to :email_job, index: true
      t.datetime :execution_time
      t.integer :job_history_status
      t.integer :total_to
      t.integer :success_to
      t.integer :fail_to
      t.string :success_to_list
      t.string :fail_to_list
      t.string :fail_errors
      t.string :job_errors

      t.timestamps
    end
  end
end
