# app/graphql/types/actor_type.rb
module Types
  class ActorType < Types::BaseObject
    field :id,         ID,      null: false
    field :kind,       String,  null: false
    field :name,       String,  null: false
    field :ref,        String,  null: false
    field :active,     Boolean, null: false
    field :metadata,   GraphQL::Types::JSON, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end