module Users
	class Base < Grape::API
		mount Users::V1::RegistrationAPI
		mount Users::V1::SessionsAPI
		mount Users::V1::CubesAPI
	end
end