require 'rails_helper'

RSpec.feature 'Users signing up' do
  let(:user) { FactoryGirl.build(:user) }
  let!(:original_user_count) { User.count }

  before do
    visit '/'
    click_link 'Sign Up'
  end
  
  feature 'with valid credentials' do
    before do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      fill_in 'user_password_confirmation', with: user.password
      fill_in 'Username', with: user.username
      click_button 'Sign up'
    end

    scenario 'succeeds and creates a new user' do
      created_user = User.last
      expect(User.count - original_user_count).to eq(1)
      expect(created_user.email).to eq(user.email)
    end

    scenario 'shows a message saying a confirmation link has been emailed' do
      expect(page).to have_content('a confirmation link has been sent to your email address')
    end
  end

  shared_examples 'a failed sign up attempt' do
    scenario 'does not create a new user' do
      expect(User.count).to eq(original_user_count)
    end
  end

  feature 'with invalid credentials' do
    before do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: 'short'
      fill_in 'user_password_confirmation', with: 'not_matching_password'
      click_button 'Sign up'
    end
    
    include_examples 'a failed sign up attempt'

    scenario 'shows messages saying why the user was not created' do
      expect(page).to have_content("Password confirmation doesn't match Password")
      expect(page).to have_content('Password is too short (minimum is 6 characters)')
    end
  end

  feature 'with no credentials' do
    before do
      click_button 'Sign up'
    end

    include_examples 'a failed sign up attempt'

    scenario 'shows messages saying why the user was not created' do
      expect(page).to have_content("Email can't be blank")
      expect(page).to have_content("Password can't be blank")
      expect(page).to have_content("Username can't be blank")
    end
  end
end
