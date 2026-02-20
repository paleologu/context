# app/graphql/types/mutation_type.rb
module Types
  class MutationType < Types::BaseObject
    field :create_entity,       mutation: Mutations::CreateEntity
    field :create_relationship, mutation: Mutations::CreateRelationship
    field :deprecate_entity,    mutation: Mutations::DeprecateEntity
  end
end