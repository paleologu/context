class IngestionController < ApplicationController
  def create
    actor = Actor.find_by(id: params[:actor_id])
    return render json: { error: "Actor not found" }, status: :not_found unless actor

    content = params[:content]
    return render json: { error: "Content is required" }, status: :unprocessable_entity if content.blank?

    result = Ingestion::Ingest.call(
      content:     content,
      actor:       actor,
      filename:    params[:filename],
      source_type: params[:source_type] || "raw"
    )

    if result.success?
      data = result.value!
      render json: {
        event_id: data[:event].id,
        entities: data[:entities].map { |e| { id: e.id, kind: e.kind, title: e.title } },
        count:    data[:entities].size
      }, status: :created
    else
      render json: { error: result.failure }, status: :unprocessable_entity
    end
  end
end
