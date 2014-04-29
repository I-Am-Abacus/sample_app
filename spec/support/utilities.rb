include ApplicationHelper
require 'spec_helper'

def spec_sign_in(user, options={})
  if options[:no_capybara]
    # Sign in when not using Capybara.
    remember_token = User.new_remember_token
    cookies[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.digest(remember_token))
  else
    visit signin_path
    valid_signin(user)
  end
end

def valid_signin(user)
  fill_in 'Email',      with: user.email
  fill_in 'Password',   with: user.password
  click_button 'Sign in'
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-error', text: message)
  end
end

RSpec::Matchers.define :have_success_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-success', text: message)
  end
end

RSpec::Matchers.define :have_notice_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-notice', text: message)
  end
end

RSpec::Matchers.define :have_full_title do |page_id|
  match do |page|
    expect(page).to have_title(full_title(page_id))
  end
end
