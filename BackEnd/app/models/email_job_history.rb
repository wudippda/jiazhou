class EmailJobHistory < ApplicationRecord
  belongs_to :email_job
  self.per_page = 5

  enum job_history_status: { fail: 0, success: 1 }, _prefix: :job_history_status
end