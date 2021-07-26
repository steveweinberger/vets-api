# frozen_string_literal: true

class AppealsApi::Docs::V2::DocsController < ApplicationController
  skip_before_action(:authenticate)

  SWAGGERED_CLASSES = [
    # AppealsApi::V2::HigherLevelReviewsControllerSwagger,
    AppealsApi::V1::NoticeOfDisagreementsControllerSwagger,
    AppealsApi::V1::Schemas::NoticeOfDisagreements,
    AppealsApi::V2::Schemas::HigherLevelReviews,
    AppealsApi::V2::SecuritySchemeSwagger,
    AppealsApi::V2::SwaggerRoot
  ].freeze

  def decision_reviews
    swagger = JSON.parse(File.read(AppealsApi::Engine.root.join('app/swagger/appeals_api/v2/swagger.json')))
    render json: swagger
  end
end
