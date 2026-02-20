# app/graphql/types/event_type.rb
module Types
  class EventType < Types::BaseObject
    field :id,         ID,     null: false
    field :event_type, String, null: false
    field :payload,    GraphQL::Types::JSON, null: false
    field :metadata,   GraphQL::Types::JSON, null: false
    field :scope,      String, null: true
    field :actor,      Types::ActorType, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end