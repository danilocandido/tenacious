require 'rails_helper'
require 'features/feature_helpers'
include FeatureHelpers

RSpec.feature 'Showing an inventory' do
  let(:member) { FactoryGirl.create(:user, :confirmed) }
  let(:user) { FactoryGirl.create(:user, :confirmed) }
  let(:inventory) { FactoryGirl.create(:inventory, users: [member]) }

  feature 'as a user not part of the inventory' do
    scenario 'responds with RecordNotFound' do
      login_as(user)
      expect { visit user_inventory_path(member, inventory) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  feature 'as a guest' do
    before do
      visit user_inventory_path(user, inventory)
    end

    will_redirect_to_login_page
  end
end
