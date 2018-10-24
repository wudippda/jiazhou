class EmailJobHistory < ApplicationRecord
  belongs_to :email_job
  enum job_history_status: { fail: 0, success: 1 }, _prefix: :job_history_status
end