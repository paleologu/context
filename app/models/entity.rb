# app/models/entity.rb
class Entity < ApplicationRecord
  belongs_to :actor

  has_neighbors :embedding

  KINDS    = %w[decision learning assumption risk topic goal constraint].freeze
  STATUSES = %w[active deprecated superseded].freeze

  validates :kind,  presence: true, inclusion: { in: KINDS }
  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :active,     -> { where(status: "active") }
  scope :by_kind,    ->(kind)  { where(kind: kind) }
  scope :by_scope,   ->(scope) { where(scope: scope) }
  scope :decisions,  -> { by_kind("decision") }
  scope :learnings,  -> { by_kind("learning") }
  scope :topics,     -> { by_kind("topic") }
  scope :assumptions,-> { by_kind("assumption") }
end