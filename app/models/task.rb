class Task < ApplicationRecord
  STATUS = %w[incomplete complete]
  PRIORITY = %w[high medium low]
  belongs_to :user
  validates :title, presence: true
  validates :status, inclusion: { in: STATUS }
  validates :priority, inclusion: { in: PRIORITY }
end
