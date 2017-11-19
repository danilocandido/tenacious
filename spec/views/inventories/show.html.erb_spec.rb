require 'rails_helper'

RSpec.describe 'inventories/show', type: :view do
  let(:admins) { FactoryGirl.build_stubbed_list(:user, 2) }
  let(:writers) { FactoryGirl.build_stubbed_list(:user, 2) }
  let(:readers) { FactoryGirl.build_stubbed_list(:user, 2) }
  let(:invited_users) { FactoryGirl.build_stubbed_list(:user, 2) }
  let(:organization) { FactoryGirl.build_stubbed(:organization) }
  let(:inventory) do
    FactoryGirl.build_stubbed(:inventory, owner: organization,
                                          admins: admins,
                                          writers: writers,
                                          readers: readers,
                                          invited_users: invited_users)
  end

  before do
    assign(:inventory, inventory)
  end

  context 'when a user at minimum has read access to the inventory' do
    before do
      allow(view).to receive(:current_user).and_return(readers.first)
      render
    end

    it "displays the inventory's information" do
      expect(rendered).to include(inventory.name)
      expect(rendered).to include(inventory.description)
    end

    it 'has a list of the users invited to the inventory' do
      invited_users.each do |invited_user|
        expect(rendered).to include(invited_user.username)
      end
    end

    it 'has a table of the confirmed users in the inventory' do
      (admins + writers + readers).each do |user|
        expect(rendered).to have_selector('table', text: user.username)
      end
    end

    it 'has a link to the organization the inventory belongs to if it exists' do
      expect(rendered).to have_link(organization.name)
    end

    it 'has no search form to invite users' do
      expect(rendered).not_to have_xpath("//form[@action = '/inventory_users/#{inventory.id}/new']")
    end
  end

  context 'when a user has admin access to the inventory' do
    before do
      allow(view).to receive(:current_user).and_return(admins.first)
      render
    end

    it 'displays a search form to invite users' do
      expect(rendered).to have_xpath("//form[@action = '/inventory_users/#{inventory.id}/new']")
    end
  end
end
