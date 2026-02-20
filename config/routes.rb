# config/routes.rb
Rails.application.routes.draw do
  post "/graphql", to: "graphql#execute"
  post "/ingest",  to: "ingestion#create"
  post "/query",   to: "query#create"

  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end

  get "up" => "rails/health#show", as: :rails_health_check
end