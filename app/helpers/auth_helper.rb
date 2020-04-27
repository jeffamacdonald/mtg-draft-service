module AuthHelper
	extend Grape::API::Helpers

	def auth_check
		return User.find(decoded_auth_token[:user_id]) if decoded_auth_token
		error!('Forbidden', 403)
	end

	def set_authenticated_user
		@user = auth_check
	end

	def decoded_auth_token
    @decoded_auth_token ||= JsonWebToken.decode(http_auth_header)
  end

	def http_auth_header
    if headers['Authorization'].present?
      return headers['Authorization'].split(' ').last
    end
    nil
  end
end