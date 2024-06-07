class Chat < ApplicationRecord
  STATUS = %w[current archived]
  belongs_to :user
  has_many :conversations, dependent: :destroy

  validates :status, inclusion: { in: STATUS }
end
