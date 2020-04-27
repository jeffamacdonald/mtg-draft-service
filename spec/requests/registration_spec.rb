require 'rails_helper'

RSpec.describe 'POST /register', type: :request do
  let(:url) { '/api/v1/users/register' }
  let(:email) {'user@example.com'}
  let(:username) {'testuser'}
  let(:phone) {'9876543210'}
  let(:password) {'password'}
  let(:params) do
    {
      email: email,
      username: username,
      phone: phone,
      password: password,
      password_confirmation: password
    }
  end

  subject { post url, params: params }

  context 'when user does not exist' do
    it 'returns 201' do
      subject
      expect(response.status).to eq 201
    end

    it 'returns a new user with correct values' do
      subject
      response_body = JSON.parse(response.body)
      expect(response_body["email"]).to eq email
      expect(response_body["username"]).to eq username
      expect(response_body["phone"]).to eq phone
    end
  end

  context 'when user already exists' do
    let!(:user) { create :user, email: params[:email] }

    it 'returns unprocessable entity status' do
      subject
      expect(response.status).to eq 422
    end

    it 'returns validation errors' do
      subject
      expect(JSON.parse(response.body)['message']).to eq('User already exists')
    end
  end

  context 'when email fails validation' do
    let(:email) { "example.com" }

    it 'returns bad request status' do
      subject
      expect(response.status).to eq 400
    end

    it 'returns validation errors' do
      subject
      expect(JSON.parse(response.body)['error']).to eq('Validation failed: Email is invalid')
    end
  end
end