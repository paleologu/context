# app/models/event.rb
class Event < ApplicationRecord
  belongs_to :actor

  validates :event_type, presence: true
  validates :actor,      presence: true

  scope :by_type,  ->(type)  { where(event_type: type) }
  scope :by_scope, ->(scope) { where(scope: scope) }
  scope :recent, -> { order(created_at: :desc) }


  before_update { raise ActiveRecord::RecordInvalid.new(self) }

end