class ClaudeService
  API_URL = "https://api.anthropic.com/v1/messages"
  MODEL = "claude-sonnet-4-5-20241022"
  MAX_TOKENS = 1200

  def initialize
    @api_key = ENV.fetch('ANTHROPIC_API_KEY')
    @conn = Faraday.new(url: API_URL) do |f|
      f.request :json
      f.response :json
      f.adapter Faraday.default_adapter
    end
  end

  def analyze_lab_results(scan)
    content_blocks = build_content_blocks(scan)
    system_prompt = PromptTemplate.current("lab_analysis")&.content || default_system_prompt

    response = @conn.post do |req|
      req.headers['x-api-key'] = @api_key
      req.headers['anthropic-version'] = '2023-06-01'
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        model: MODEL,
        max_tokens: MAX_TOKENS,
        system: system_prompt,
        messages: [{ role: "user", content: content_blocks }]
      }
    end

    raise "Claude API error: #{response.status}" unless response.status == 200

    text = response.body["content"]
      &.select { |c| c["type"] == "text" }
      &.map { |c| c["text"] }
      &.join("")

    clean = text.gsub(/```json|```/, "").strip
    JSON.parse(clean)
  end

  private

  def build_content_blocks(scan)
    blocks = []

    scan.lab_files.each do |file|
      blocks << file_to_block(file)
    end

    if scan.prescription_files.attached?
      blocks << { type: "text", text: "The following file(s) are the patient's prescription / doctor's order. Use them as context for interpreting the lab results above:" }
      scan.prescription_files.each do |file|
        blocks << file_to_block(file)
      end
    end

    blocks << { type: "text", text: "Please analyze these lab results and respond with the JSON structure as instructed." }
    blocks
  end

  def file_to_block(file)
    data = Base64.strict_encode64(file.download)
    content_type = file.content_type

    if content_type == "application/pdf"
      { type: "document", source: { type: "base64", media_type: "application/pdf", data: data } }
    else
      { type: "image", source: { type: "base64", media_type: content_type, data: data } }
    end
  end

  def default_system_prompt
    <<~PROMPT
      You are Labriq, a medical lab results interpreter that helps patients prepare for doctor visits. You are NOT a doctor and must NEVER diagnose or recommend treatment.

      Your job:
      1. Extract lab values from the provided files
      2. If a prescription is provided, use it as context for better interpretation
      3. Identify which values are normal, high, or low
      4. Explain findings in plain language (8th-grade reading level)
      5. Generate smart questions for the doctor
      6. Flag any critical/urgent values

      RESPOND ONLY WITH THIS EXACT JSON (no markdown, no backticks):
      {
        "summary": "2-3 sentence plain-language summary",
        "prescription_context": "1 sentence about prescription relation to results, or null",
        "urgency": "normal" | "attention" | "urgent",
        "urgency_note": "Only if urgent: why they should see a doctor soon",
        "values": [
          {
            "name": "Test Name",
            "value": "123",
            "unit": "mg/dL",
            "status": "normal" | "high" | "low" | "critical",
            "reference": "70-100",
            "explanation": "One sentence plain language"
          }
        ],
        "questions_for_doctor": ["Question 1", "Question 2", "Question 3"],
        "lifestyle_tips": ["Tip 1", "Tip 2"]
      }

      Rules:
      - Summary under 3 sentences
      - Simple language a teenager would understand
      - Never say "you have" or "you are diagnosed with"
      - Always include at least 3 doctor questions
      - Be conservative — when in doubt, recommend asking the doctor
    PROMPT
  end
end
