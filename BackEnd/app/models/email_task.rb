class EmailTask < ApplicationRecord
  belongs_to :email_job

  validates :task_params, :task_type_id, presence: true
end
