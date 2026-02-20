# app/graphql/types/relationship_type.rb
module Types
  class RelationshipType < Types::BaseObject
    field :id,        ID,     null: false
    field :from_id,   ID,     null: false
    field :from_type, String, null: false
    field :to_id,     ID,     null: false
    field :to_type,   String, null: false
    field :predicate, String, null: false
    field :metadata,  GraphQL::Types::JSON, null: false
    field :actor,     Types::ActorType, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end