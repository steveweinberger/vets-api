# frozen_string_literal: true

module AuthenticationSystemHelpers
  def expect_logged_in_home_screen
    expect(page).to have_content('My Health')
    expect(page).not_to have_content('Sign in')
  end
end
