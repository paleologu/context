# app/models/actor.rb
class Actor < ApplicationRecord
  has_many :events
  has_many :entities
  has_many :relationships

  enum :kind, { human: "human", agent: "agent" }, prefix: true

  validates :ref, presence: true, uniqueness: { scope: :kind }
  validates :name, presence: true
  validates :kind, presence: true
end