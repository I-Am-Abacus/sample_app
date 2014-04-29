require 'spec_helper'
require 'support/utilities'

describe 'User pages' do

  subject { page }

  describe 'index' do

    let(:user) { FactoryGirl.create(:user) }

    before do
      spec_sign_in user
      visit users_path
    end

    it { should have_full_title('All users') }
    it { should have_content('All users') }

    describe 'pagination' do

      before(:all)  { 30.times { FactoryGirl.create(:user) } }
      after(:all)   { User.delete_all}

      it { should have_selector('div.pagination') }

      it 'should list each user' do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text: user.name)
        end
      end
    end

    describe 'delete links' do

      it { should_not have_link('delete') }

      describe 'as an admin user' do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          spec_sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it 'should be able to delete another user' do
          expect do
            click_link('delete', match: :first)
          end.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin)) }
      end
    end
  end

  describe 'profile page' do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { should have_content(user.name) }
    # it { should have_title(user.name) }
    # it { should have_title(full_title(user.name)) }
    it { should have_full_title(user.name) }
  end

  describe 'signup page' do
    before { visit signup_path }

    it { should have_content('Sign up') }
    it { should have_full_title('Sign up') }
  end

  describe 'signup' do
    before { visit signup_path }

    let(:submit) { 'Create my account' }          # Submit button

    # describe 'with no fields filled' do
    #   it 'should return the correct error messages' do
    #     click_button submit
    #
    #
    #   end
    # end

    describe 'with invalid information' do
      it 'should not create a user' do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe 'after submission with empty fields' do
        before { click_button submit }

        it { should have_full_title('Sign up') }

        it { should have_selector('li', text:'Name can\'t be blank') }
        it { should have_selector('li', text:'Email can\'t be blank') }
        it { should have_selector('li', text:'Email is invalid') }
        it { should have_selector('li', text:'Password can\'t be blank') }
        it { should have_selector('li', text:'Password is too short (minimum is 6 characters')}
      end

      describe 'after submission with invalid email' do
        before do
          fill_in 'Email',     with: 'foobar'
          click_button submit
        end

        it { should have_selector('li', text:'Email is invalid') }
      end

      describe 'after submission with mismatched passwords' do
        before do
          fill_in 'Password',     with: 'foobar'
          click_button submit
        end

        it { should have_selector('li', text:'Password confirmation can\'t be blank') }
      end
    end

    describe 'with valid information' do
      before do
        fill_in 'Name',         with: 'Example user'
        fill_in 'Email',        with: 'user@example.com'
        fill_in 'Password',     with: 'foobar'
        fill_in 'Confirmation', with: 'foobar'
      end

      it 'should create a user' do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe 'after saving the user' do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user@example.com') }

        it { should have_link('Sign out') }
        it { should have_full_title(user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
      end
    end
  end

  describe 'edit' do
    let(:user) { FactoryGirl.create(:user) }
    before do
      spec_sign_in user
      visit(edit_user_path(user))
    end

    describe 'page' do
      it { should have_content('Update your profile') }
      it { should have_full_title('Edit user') }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe 'with invalid information' do
      before { click_button 'Save changes' }

      it { should have_content('error') }
    end

    describe 'with valid information' do
      let(:new_name)  { 'New Name' }
      let(:new_email) { 'new@example.com' }
      before do
        fill_in 'Name',                   with: new_name
        fill_in 'Email',                  with: new_email
        fill_in 'Password',               with: user.password
        fill_in 'Password confirmation',  with: user.password
        click_button 'Save changes'
      end

      it { should have_full_title(new_name) }
      it { should have_success_message('Profile updated') }
      it { should have_link('Sign out', href: signout_path) }

      let(:reloaded_user) { user.reload }
      specify { expect(reloaded_user.name).to eq(new_name) }
      specify { expect(reloaded_user.email).to eq(new_email) }
    end
  end
end
