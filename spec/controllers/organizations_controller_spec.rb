require 'rails_helper'

RSpec.describe OrganizationsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:user_not_in_org) { FactoryGirl.build_stubbed(:user) }
  let(:organization) { FactoryGirl.create(:organization, owner: user) }
  let(:inventories) { FactoryGirl.create_list(:inventory, 2, owner: organization) }

  describe '#show' do
    before do
      allow(subject).to receive(:params).and_return(id: organization.id)
      allow(subject).to receive(:redirect_to)
    end

    context 'when user is a part of the organization' do
      before do
        allow(subject).to receive(:current_user).and_return(user)
      end

      it 'assigns @organization' do
        subject.show
        expect(subject.view_assigns['organization']).to eq organization
      end
    end

    context 'when user is not a part of the organization' do
      before do
        allow(subject).to receive(:current_user).and_return(user_not_in_org)
      end

      it 'sets an alert flash stating user needs to be a part of the org' do
        subject.show
        expect(flash[:alert]).to eq 'You need to be part of this organization to view it'
      end

      it 'redirects to root path' do
        expect(subject).to receive(:redirect_to).with(root_path)
        subject.show
      end
    end
  end
end
