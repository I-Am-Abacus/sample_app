include ApplicationHelper
require 'spec_helper'

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

RSpec::Matchers.define :have_full_title do |page_id|
  match do |page|
    expect(page).to have_title(full_title(page_id))
  end
end
