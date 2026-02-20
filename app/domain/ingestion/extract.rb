module Ingestion
  class Extract
    PROMPT = <<~PROMPT
      You are a knowledge extraction agent. Your job is to read source material and extract structured knowledge from it.

      Extract the following entity types:
      - decision: A committed directional choice that was made. Must have a clear chosen option and rationale.
      - learning: A validated insight derived from experience or evidence.
      - assumption: An unvalidated belief the author is operating on.
      - risk: A potential negative outcome that was identified.
      - topic: A subject area or theme that organizes other entities.

      Return ONLY valid JSON in this exact structure, nothing else:

      {
        "entities": [
          {
            "kind": "decision",
            "title": "Short descriptive title",
            "summary": "One sentence summary",
            "confidence": 0.9,
            "body": {
              "chosen_option": "What was decided",
              "rationale": "Why this was decided",
              "alternatives": ["Other option 1", "Other option 2"],
              "assumptions": ["Assumption made"],
              "risks": ["Risk identified"]
            }
          },
          {
            "kind": "learning",
            "title": "Short descriptive title",
            "summary": "One sentence summary",
            "confidence": 0.8,
            "body": {
              "statement": "The insight itself",
              "evidence_summary": "What evidence supports this"
            }
          },
          {
            "kind": "assumption",
            "title": "Short descriptive title",
            "summary": "One sentence summary",
            "confidence": 0.6,
            "body": {
              "statement": "The assumption being made",
              "basis": "Why this assumption exists"
            }
          },
          {
            "kind": "risk",
            "title": "Short descriptive title",
            "summary": "One sentence summary",
            "confidence": 0.7,
            "body": {
              "statement": "The risk",
              "likelihood": "low|medium|high",
              "impact": "low|medium|high",
              "mitigation": "How to mitigate if known"
            }
          },
          {
            "kind": "topic",
            "title": "Topic name",
            "summary": "What this topic covers",
            "confidence": null,
            "body": {
              "description": "Brief description of the topic"
            }
          }
        ],
        "relationships": [
          {
            "from_index": 0,
            "to_index": 2,
            "predicate": "about"
          }
        ]
      }

      Relationships use array indexes from the entities array above.
      Only use these predicates: about, informed_by, contradicts, validates, supersedes, depends_on, triggered_by, related_to.
      Only extract what is clearly present in the source. Do not invent entities.
      Return only JSON, no explanation, no markdown fences.
    PROMPT

    def self.call(content:)
      uri  = URI("https://api.groq.com/openai/v1/chat/completions")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri)
      request["Content-Type"]  = "application/json"
      request["Authorization"] = "Bearer #{ENV["GROQ_API_KEY"]}"
      request.body = JSON.generate({
        model:       "llama-3.3-70b-versatile",
        temperature: 0,
        messages:    [
          { role: "system", content: PROMPT },
          { role: "user",   content: "Extract knowledge from this source material:\n\n#{content}" }
        ]
      })

      response = http.request(request)
      body     = JSON.parse(response.body)
      text     = body.dig("choices", 0, "message", "content")

      # Strip markdown fences if model returns them
      text = text.gsub(/\A```(?:json)?\n?/, "").gsub(/\n?```\z/, "").strip

      parsed = JSON.parse(text)
      Success(parsed)
    rescue JSON::ParserError => e
      Failure({ llm: "Failed to parse LLM response: #{e.message}" })
    rescue => e
      Failure({ llm: "LLM request failed: #{e.message}" })
    end
  end
end
