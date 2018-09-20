require 'spec_helper'
require 'pry'

RSpec.describe FarmsController, type: :controller do
  let(:locale) { 'en' }
  let!(:user) { User.create(username: 'Ria', email: 'ria@gmail.com', password: 'meow') }
  let(:farm) { Farm.create(name: 'Cattail Farm', location: 'Ohio', user_id: user.id) }

  describe 'farm show page' do
    before do
      visit "/#{locale}/login"

      fill_in(:username, with: 'Ria')
      fill_in(:password, with: 'meow')
      click_button 'submit'
    end

    it 'loads the farm page' do
      get "/#{locale}/farms/#{farm.id}/#{farm.slug}"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include(farm.name)
      expect(last_response.body).to include(farm.location)
    end
  end

  describe 'new farm page' do
    context 'when logged in' do
      it 'loads the new farm form' do
        visit "/#{locale}/login"

        fill_in(:username, with: 'Ria')
        fill_in(:password, with: 'meow')
        click_button 'submit'

        visit "/#{locale}/farms/new"

        expect(page.status_code).to eq(200)
        expect(page.body).to include('Create a new farm')
      end
    end

    context 'when logged out' do
      it 'redirects the user to login' do
        get "/#{locale}/farms/new"

        expect(last_response.location).to include("/#{locale}/login")
      end
    end
  end

  describe 'creating a new farm' do
    it 'lets user create a new farm' do
      visit "/#{locale}/login"

      fill_in(:username, with: 'Ria')
      fill_in(:password, with: 'meow')
      click_button 'submit'

      visit "/#{locale}/farms/new"

      fill_in(:name, with: 'My Farm')
      fill_in(:location, with: 'Catland')
      click_button 'submit'

      farm = Farm.find_by(name: 'My Farm')
      expect(farm).to be_instance_of(Farm)
      expect(farm.user_id).to eq(user.id)

      visit "/#{locale}/farms/#{farm.id}/#{farm.slug}"
      expect(page.status_code).to eq(200)
    end
  end

  describe 'editing a farm' do
    before do
      visit "/#{locale}/login"

      fill_in(:username, with: 'Ria')
      fill_in(:password, with: 'meow')
      click_button 'submit'
    end

    context 'when logged in' do
      it 'lets user edit a farm' do
        visit "/#{locale}/farms/#{farm.id}/#{farm.slug}/edit"

        fill_in(:name, with: 'Cattail Farm Edited')
        fill_in(:location, with: 'Catlandia')
        click_button 'save'

        expect(Farm.find_by(name: 'Cattail Farm Edited')).to be_instance_of(Farm)
        expect(Farm.find_by(name: 'Cattail Farm')).to eq(nil)
      end
    end

    context 'when logged out' do
      it 'does not allow logged out user to edit a farm' do
        get "/#{locale}/logout"
        get "/#{locale}/farms/#{farm.id}/#{farm.slug}/edit"

        expect(last_response.location).to include("/#{locale}/")
      end

      it 'does not show the edit button on the farm page' do
        get "/#{locale}/logout"
        get "/#{locale}/farms/#{farm.id}/#{farm.slug}"

        expect(last_response.body).not_to include('Edit farm')
      end
    end
  end

  describe 'deleting a farm' do
    it 'lets users delete a farm' do
      visit "/#{locale}/login"

      fill_in(:username, with: 'Ria')
      fill_in(:password, with: 'meow')
      click_button 'submit'

      visit "/#{locale}/farms/#{farm.id}/#{farm.slug}/edit"

      click_button 'delete'
      expect(Farm.find_by(name: 'Cattail Farm')).to eq(nil)
    end
  end
end
