class CreateEmailJobs < ActiveRecord::Migration[5.1]
  def change
    create_table :email_jobs do |t|

      t.timestamps
    end
  end
end
