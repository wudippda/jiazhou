class CreateEmailJobHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :email_job_histories do |t|
      t.datetime :execution_time
      t.integer :status
      t.integer :total_to
      t.integer :success_to
      t.integer :fail_to
      t.string :success_to_list
      t.string :fail_to_list

      t.timestamps
    end
  end
end
