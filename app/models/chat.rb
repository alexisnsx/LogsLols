class Chat < ApplicationRecord
  STATUS = %w[current archive]
  belongs_to :user
  has_many :conversations

  validates :status, inclusion: { in: STATUS }
end
