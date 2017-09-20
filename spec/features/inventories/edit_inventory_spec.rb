require 'rails_helper'
require 'features/feature_helpers'
include FeatureHelpers

RSpec.feature 'Editing an inventory' do
  let(:org_owner) { FactoryGirl.create(:user, :confirmed) }
  let(:member) { FactoryGirl.create(:user, :confirmed) }
  let(:inventory) { FactoryGirl.create(:inventory, owner: org_owner, users: [org_owner]) }
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
        scenario "and doesn't save the inventory" do
          expect(page).to have_content("Name can't be blank")
        end
      end
    end
  end

  shared_examples 'a successful inventory edition' do |owner_string|
    feature 'with valid inputs' do
      if owner_string == 'organization'
        let(:owner) { organization }
      elsif owner_string == 'org_owner'
        let(:owner) { org_owner }
      end

      let(:new_name) { 'new name' }
      let(:new_description) { 'new description' }

      before do
        fill_in 'inventory_name', with: new_name
        fill_in 'inventory_description', with: new_description
        click_button 'Edit Inventory'
      end

      feature 'success' do
        let(:edited_inventory) { Inventory.last }

        scenario 'and edit the inventory to the database' do
          expect(Inventory.count).to eq(1)
        end

        scenario 'and has the same attributes as input edited into the form' do
          expect(edited_inventory.name).to eq(new_name)
          expect(edited_inventory.description).to eq(new_description)
        end

        scenario 'and sets the owner as the owner of the inventory' do
          expect(edited_inventory.owner).to eq(owner)
        end

        scenario 'and includes the user as part of the inventory' do
          expect(edited_inventory.users).to include(org_owner)
        end

        scenario 'and redirects to the inventory path' do
          if owner_string == 'organization'
            expect(current_path).to eq(organization_inventory_path(owner, edited_inventory))
          elsif owner_string == 'org_owner'
            expect(current_path).to eq(user_inventory_path(owner, edited_inventory))
          end
        end

        scenario 'and shows a message saying the inventory was edited' do
          expect(page).to have_content('Your inventory has been successfully edited')
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

    include_examples 'a successful inventory edition', 'org_owner'
  end

end