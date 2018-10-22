class EmailJobHistory < ApplicationRecord
  belongs_to :email_job

  enum status: { fail: 0, success: 1 }
end