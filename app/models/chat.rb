class Chat < ApplicationRecord
  STATUS = %w[current archive]
  belongs_to :user

  validates :status, inclusion: { in: STATUS }
end
