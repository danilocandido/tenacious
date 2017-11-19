require 'rails_helper'
require 'features/feature_helpers'
include FeatureHelpers

RSpec.feature 'Visiting dashboard route' do
  feature 'as a guest' do
    before do
      visit dashboard_path
    end

    will_redirect_to_login_page
  end
end
