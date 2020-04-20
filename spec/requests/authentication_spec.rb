require 'rails_helper'

RSpec.describe 'POST /login', type: :request do
	let(:user) { create :user }
  let(:url) { '/users/login' }
  let(:params) do
    {
      user: {
        email: user.email,
        password: user.password
      }
    }
  end

  subject { post url, params: params }

  context 'when params are correct' do
  	it 'returns 200' do
  		subject
  		expect(response.status).to eq 200
  	end

  	it 'returns JWT in authorization header' do
  		subject
  		expect(response.headers['Authorization']).to be_present
  	end
  end

  context 'when params are incorrect' do
  	let(:params) do
  		{
  			user: {
	  			email: user.email
	  		}
	  	}
  	end
  	it 'returns 401' do
  		subject
  		expect(response.status).to eq 401
  	end
  end
end

RSpec.describe 'DELETE /logout', type: :request do
  let(:url) { '/users/logout' }

  subject { delete url }

  it 'returns 204, no content' do
    subject
    expect(response.status).to eq 204
  end
end