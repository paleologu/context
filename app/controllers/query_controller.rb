# app/controllers/query_controller.rb
class QueryController < ApplicationController
  def create
    question = params[:question]
    return render json: { error: "Question is required" }, status: :unprocessable_entity if question.blank?

    result = Querying::Ask.call(question: question)

    if result.success?
      render json: result.value!, status: :ok
    else
      render json: { error: result.failure }, status: :unprocessable_entity
    end
  end
end