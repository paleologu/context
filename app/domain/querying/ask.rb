# app/domain/querying/ask.rb
module Querying
  class Ask
    SYSTEM_PROMPT = <<~PROMPT
      You are a knowledge base assistant. You answer questions about organizational decisions, learnings, assumptions, risks, and topics that have been recorded in a knowledge graph.

      You will be given a question and a set of relevant entities retrieved from the knowledge base. Each entity has a kind, title, summary, body, and confidence score.

      Answer the question based only on the provided entities. Be specific and cite which entities support your answer. If the entities don't contain enough information to answer the question, say so clearly.

      Be concise. Lead with the answer, then support it with evidence from the entities.
    PROMPT

    def self.call(question:, limit: 10)
      # Fetch relevant entities by keyword match across title and summary
      entities = Entity.active
        .where("title ILIKE :q OR summary ILIKE :q", q: "%#{question}%")
        .limit(limit)

      # Fall back to recent entities if nothing matches
      if entities.empty?
        entities = Entity.active.order(created_at: :desc).limit(limit)
      end

      return Failure({ query: "No entities in knowledge base yet" }) if entities.empty?

      context = entities.map do |e|
        <<~ENTITY
          [#{e.kind.upcase}] #{e.title}
          Summary: #{e.summary}
          Body: #{e.body.to_json}
          Confidence: #{e.confidence || "unscored"}
        ENTITY
      end.join("\n---\n")

      uri  = URI("https://api.groq.com/openai/v1/chat/completions")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri)
      request["Content-Type"]  = "application/json"
      request["Authorization"] = "Bearer #{ENV["GROQ_API_KEY"]}"
      request.body = JSON.generate({
        model:       "llama-3.3-70b-versatile",
        temperature: 0.3,
        messages:    [
          { role: "system", content: SYSTEM_PROMPT },
          {
            role:    "user",
            content: "Question: #{question}\n\nRelevant entities from the knowledge base:\n\n#{context}"
          }
        ]
      })

      response = http.request(request)
      body     = JSON.parse(response.body)
      answer   = body.dig("choices", 0, "message", "content")

      Success({
        answer:   answer,
        entities: entities.map { |e| { id: e.id, kind: e.kind, title: e.title } },
        count:    entities.size
      })
    rescue => e
      Failure({ query: "Query failed: #{e.message}" })
    end
  end
end