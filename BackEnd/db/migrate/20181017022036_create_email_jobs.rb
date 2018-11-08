class CreateEmailJobs < ActiveRecord::Migration[5.1]
  def change
    create_table :email_jobs do |t|
      t.integer :job_status, default: 0
      t.datetime :next_time
      t.string :from
      t.string :to
      t.string :job_name
      t.string :config
      t.string :job_type
      t.timestamps
      t.index [:job_name], :unique => true
    end
  end
end
