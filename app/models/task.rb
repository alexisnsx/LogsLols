class Task < ApplicationRecord
  include PgSearch::Model
  has_rich_text :content

  STATUS = %w[Incomplete Complete]
  PRIORITY = %w[High Medium Low]
  belongs_to :user
  has_many_attached :documents
  validates :title, presence: true
  validates :status, inclusion: { in: STATUS }
  validates :priority, inclusion: { in: PRIORITY }

  pg_search_scope :search_full_text, against: {
    title: 'A',
  },
  associated_against: {
    rich_text_content: [:body] # Associated against the ActionText content
}, using: {
    tsearch: { prefix: true }
  }
end
