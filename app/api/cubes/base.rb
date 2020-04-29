module Cubes
	class Base < Grape::API
		mount Cubes::V1::CubesAPI
	end
end