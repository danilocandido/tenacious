require 'rails_helper'
require 'features/feature_helpers'
include FeatureHelpers

RSpec.feature 'Editing an inventory' do
  let(:org_owner) { FactoryGirl.create(:user, :confirmed) }
  let(:member) { FactoryGirl.create(:user, :confirmed) }
  let(:inventory) { FactoryGirl.create(:inventory, owner: org_owner) }
  let!(:organization) { FactoryGirl.create(:organization, owner: org_owner, users: [org_owner, member]) }
  let!(:original_inventory_count) { Inventory.count }

  shared_examples 'a failed inventory edition' do
    feature 'with no inputs' do
      before do
        fill_in 'inventory_name', with: ''
        fill_in 'inventory_description', with: ''
        click_button 'Edit Inventory'
      end

      feature 'fails' do
        scenario "and doesn't save the inventory to the database" do
          #puts Inventory.count #test -> returned value 1
          #puts original_inventory_count #test -> returned value 0
          expect(Inventory.count).to eq(original_inventory_count)
        end
      end
    end
  end

  feature 'as a user through the user route' do
    before do
      login_as(org_owner)
      visit '/'
      visit dashboard_path
      visit edit_user_inventory_path(inventory.owner, inventory)
    end

    scenario 'shows that the inventory will be edited under the user' do
      expect(page).to have_content('Edit an Inventory for yourself')
    end

    include_examples 'a failed inventory edition'
  end

end