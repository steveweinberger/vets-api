# frozen_string_literal: true

module BGS
  class DisabilityRatingService
    def get_rating(current_user)
      service = BGS::Services.new(
        external_uid: current_user.icn || current_user.ssn,
        external_key: current_user.email || current_user.ssn
      )
      service.rating.find_rating_data(current_user.ssn)
    end
  end
end
