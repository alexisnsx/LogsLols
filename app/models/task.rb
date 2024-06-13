class Task < ApplicationRecord
  STATUS = %w[Incomplete Complete]
  PRIORITY = %w[High Medium Low]
  belongs_to :user
  has_many_attached :documents
  validates :title, presence: true
  validates :status, inclusion: { in: STATUS }
  validates :priority, inclusion: { in: PRIORITY }

  def self.search(query)
    if query.present?
      where('title LIKE ? OR content LIKE ?', "%#{task}%")
    else
      all
    end
  end
end
