module Drafts
	class Base < Grape::API
		mount Drafts::V1::SetupAPI
	end
end