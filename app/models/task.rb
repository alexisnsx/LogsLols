class Task < ApplicationRecord
  include PgSearch::Model
  has_rich_text :content

  PRIORITY_ORDER = {
    'High' => 1,
    'Medium' => 2,
    'Low' => 3
  }

  scope :ordered_by_priority, -> {
    order(Arel.sql("CASE priority
                      WHEN 'High' THEN 1
                      WHEN 'Medium' THEN 2
                      WHEN 'Low' THEN 3
                    END"))
  }

  scope :ordered_by_status, -> {
    order(Arel.sql("CASE status
                      WHEN 'Incomplete' THEN 1
                      WHEN 'Complete' THEN 2
                    END"))
  }

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
