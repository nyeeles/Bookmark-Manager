require 'spec_helper'
require_relative 'helpers/session'

include SessionHelpers

feature "User signs in" do

  before(:each) do
    User.create(:email => "test@test.com", :password => 'test', :password_confirmation => 'test')
  end

  scenario "with correct credentials" do
    visit '/'
    expect(page).not_to have_content("Welcome, test@test.com")
    sign_in('test@test.com', 'test')
    expect(page).to have_content("Welcome, test@test.com")
  end

  scenario "with incorrect credentials" do
    visit '/'
    expect(page).not_to have_content("Welcome, test@test.com")
    sign_in('test@test.com', 'wrong')
    expect(page).not_to have_content("Welcome, test@test.com")
  end
end

feature 'User signs out' do

  before(:each) do
    User.create(:email => "test@test.com", :password => 'test', :password_confirmation => 'test')
  end

  scenario 'while being signed in' do
    sign_in('test@test.com', 'test')
    click_button "Sign out"
    expect(page).to have_content("Good bye!")
    expect(page).not_to have_content("Welcome, test@test.com")
  end
end

feature "User signs up" do

  scenario "when being logged out" do    
    lambda { sign_up }.should change(User, :count).by(1)    
    expect(page).to have_content("Welcome, alice@example.com")
    expect(User.first.email).to eq("alice@example.com")        
  end

  scenario "with a password that doesn't match" do
    lambda { sign_up('a@a.com', 'pass', 'wrong') }.should change(User, :count).by(0) 
    expect(current_path).to eq('/users')   
    expect(page).to have_content("Sorry, your passwords don't match")
  end

  scenario "with an email that is already registered" do    
    lambda { sign_up }.should change(User, :count).by(1)
    lambda { sign_up }.should change(User, :count).by(0)
    expect(page).to have_content("This email is already taken")
  end
end

feature "User requests for password reset" do
  before(:each) do
    User.create(:email => "test@test.com", :password => 'test', :password_confirmation => 'test')
  end

  scenario 'when on the log in page' do
    visit('/sessions/new')
    click_link 'Forgot password'
    expect(page).to have_content "Enter your email"
  end

  scenario 'when submitting for a new password' do
    visit('/users/reset_password')
    fill_in('email', :with => 'test@test.com')
    expect(User.first.password_token).to be nil
    expect(User.first.password_token_timestamp).to be nil
    click_button 'Gimme my password!'
    expect(page).to have_content 'Please check your email for a new password'
    expect(User.first.password_token).not_to be nil
    expect(User.first.password_token_timestamp).not_to be nil

  end

  scenario 'once user clicks on email' do
    visit('/users/reset_password')
    fill_in('email', :with => 'test@test.com')
    click_button 'Gimme my password!'
    token = User.first.password_token
    visit("/users/reset_password/#{token}")
    expect(page).to have_content "Enter your new password"
    # fill_in('password', :with => 'test')
    # fill_in('confirm_password', :with => 'test')
    # click_button 'Reset password'
    # expect(token).to be nil
    # expect(page).to have_content "success"
  end

end

