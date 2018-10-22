class EmailJob < ApplicationRecord
  has_many :email_job_histories
  self.per_page = 5

  enum job_type: { now: 'now', schedule: 'schedule', delay: 'delay' }
  enum status: { idle: 0, scheduled: 1, active: 2 }

  validates :job_name, :job_type, :from, :to, :report_start, :report_end, presence: {message: 'value must be present for an email job'}
  validates :job_type, inclusion: { in: EmailJob::job_types.keys, message: "%{value} is not a valid job_type for email job" }
  validates :job_name, uniqueness: true

end
