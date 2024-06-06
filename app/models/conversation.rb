class Conversation < ApplicationRecord
  belongs_to :chat

  validates :user_message, presence: true
end
