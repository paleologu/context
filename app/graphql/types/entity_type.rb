# app/graphql/types/entity_type.rb
module Types
  class EntityType < Types::BaseObject
    field :id,         ID,     null: false
    field :kind,       String, null: false
    field :title,      String, null: false
    field :summary,    String, null: true
    field :body,       GraphQL::Types::JSON, null: false
    field :status,     String, null: false
    field :confidence, Float,  null: true
    field :scope,      String, null: true
    field :actor,      Types::ActorType, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :relationships, [Types::RelationshipType], null: false

    def relationships
      Relationship.from_entity(object.id)
    end
  end
end