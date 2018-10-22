class EmailJob < ApplicationRecord
  has_many :email_job_histories
  self.per_page = 5

  enum job_type: { now: 'now', schedule: 'schedule', delay: 'delay' }
  enum job_status: { idle: 0, scheduled: 1, active: 2 }, _prefix: :job_status

  validates :job_name, :job_type, :from, :to, :report_start, :report_end, presence: {message: 'value must be present for an email job'}
  validates :from, format: { with: URI::MailTo::EMAIL_REGEXP, message: "'%{value}' is not a valid email format" }
  #validates :report_end, :report_start, format: { with: /\p{Digit}{1,2}\/\p{Digit}{4}/, message: "'%{value}' is not a valid date format" }
  validates :job_type, inclusion: { in: EmailJob::job_types.keys, message: "%{value} is not a valid job_type for email job" }
  validates :status, inclusion: { in: EmailJob::job_statuses.values, message: "%{value} is not a valid status for email job" }
  validates :job_name, uniqueness: true

end
