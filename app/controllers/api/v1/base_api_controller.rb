class Api::V1::BaseApiController < ApplicationController
  protect_from_forgery
  include DeviseTokenAuth::Concerns::SetUserByToken
end
