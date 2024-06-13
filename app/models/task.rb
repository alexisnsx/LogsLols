class Task < ApplicationRecord
  include PgSearch::Model

  STATUS = %w[Incomplete Complete]
  PRIORITY = %w[High Medium Low]
  belongs_to :user
  has_many_attached :documents
  validates :title, presence: true
  validates :status, inclusion: { in: STATUS }
  validates :priority, inclusion: { in: PRIORITY }

  pg_search_scope :search_full_text, against: {
    title: 'A',
    description: 'B'
  }, using: {
    tsearch: { prefix: true }
  }
end
