class Task < ApplicationRecord
  STATUS = %w[Incomplete Complete]
  PRIORITY = %w[High Medium Low]
  belongs_to :user
  has_many_attached :documents
  validates :title, presence: true
  validates :status, inclusion: { in: STATUS }
  validates :priority, inclusion: { in: PRIORITY }
end
