class CreateEmailTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :email_tasks do |t|
      t.belongs_to :email_job, index: true
      t.integer :task_type_id
      t.string :task_params
      t.timestamps
    end
  end
end
