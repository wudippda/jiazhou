class EmailJob < ApplicationRecord
  has_many :email_job_histories

  validates :job_name, presence: {message: 'job name must be present for a schedule job'}
end
