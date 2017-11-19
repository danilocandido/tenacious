require 'rails_helper'

RSpec.describe 'organizations/show', type: :view do
  let(:owner) { FactoryGirl.build_stubbed(:user) }
  let(:member) { FactoryGirl.build_stubbed(:user) }
  let(:inventories) { FactoryGirl.build_stubbed_list(:inventory, 2) }
  let(:organization) { FactoryGirl.build_stubbed(:organization, owner: owner, users: [owner, member], owned_inventories: inventories) }

  before do
    assign(:organization, organization)
  end

  context 'when user is at minimum a member of the org' do
    before do
      allow(view).to receive(:current_user).and_return(member)
      render
    end

    it "displays the organization's name" do
      expect(rendered).to include organization.name
    end

    it "displays links to the organization's inventories" do
      organization.owned_inventories.each do |inventory|
        expect(rendered).to have_link(inventory.name)
      end
    end

    it 'does not display a Create an Inventory link to non-owners' do
      expect(rendered).not_to have_link('Create an Inventory')
    end
  end

  context 'when user is an owner of the org' do
    before do
      allow(view).to receive(:current_user).and_return(owner)
      render
    end

    it 'displays a Create an Inventory link to owners' do
      expect(rendered).to have_link('Create an Inventory')
    end
  end
end
