module AuthHelper
	extend Grape::API::Helpers

	def auth_check
		if decoded_auth_token && JwtBlacklist.find_by(jti: decoded_auth_token[:jti]).nil?
			User.find(decoded_auth_token[:user_id])
		else
			error!('Forbidden', 403)
		end
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