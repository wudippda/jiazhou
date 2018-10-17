class CreateEmailJobHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :email_job_histories do |t|

      t.timestamps
    end
  end
end
