# app/models/relationship.rb
class Relationship < ApplicationRecord
  belongs_to :actor

  validates :from_id,   presence: true
  validates :from_type, presence: true
  validates :to_id,     presence: true
  validates :to_type,   presence: true
  validates :predicate, presence: true,
    inclusion: { in: Relationships::PredicateVocabulary::ALL }

  scope :by_predicate, ->(predicate) { where(predicate: predicate) }
  scope :from_entity,  ->(id)        { where(from_id: id, from_type: "Entity") }
  scope :to_entity,    ->(id)        { where(to_id: id, to_type: "Entity") }
end