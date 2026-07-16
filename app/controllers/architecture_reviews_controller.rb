class ArchitectureReviewsController < ApplicationController
  layout "architecture_review"

  def show
    catalog = ArchitectureReview::Catalog.new
    @findings = catalog.findings
    @finding_count = catalog.finding_count
    @domains = catalog.domains
    @bosses = @findings.select { |finding| finding[:severity] == "critical" }
  end
end
