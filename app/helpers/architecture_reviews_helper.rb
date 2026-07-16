module ArchitectureReviewsHelper
  def review_finding_data(finding, target: false)
    {
      review_quest_target: ("card" if target),
      ids: finding[:ids].to_json,
      finding_id: finding[:id],
      title: finding[:title],
      domain: finding[:domain],
      severity: finding[:severity],
      priority: finding[:priority],
      impact: finding[:impact],
      next_action: finding[:action],
      effort: finding[:effort],
      search_text: [ finding[:id], finding[:title], finding[:domain], finding[:impact], finding[:action] ].join(" ").downcase
    }.compact
  end

  def review_severity_label(severity)
    {
      "critical" => "Boss",
      "high" => "Hoch",
      "medium" => "Mittel",
      "low" => "Niedrig"
    }.fetch(severity)
  end
end
