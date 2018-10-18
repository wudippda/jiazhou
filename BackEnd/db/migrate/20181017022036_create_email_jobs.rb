class CreateEmailJobs < ActiveRecord::Migration[5.1]
  def change
    create_table :email_jobs do |t|
      t.integer :status
      t.string :from
      t.string :to
      t.string :job_name
      t.string :config
      t.boolean :isSchedule
      t.timestamps
    end
  end
end
