# frozen_string_literal: true
require_relative 'spec_helper'

describe 'API basics' do
  it 'should find configuration information' do
    FaceGroupsAPI.config.FB_CLIENT_ID.length.must_be :>, 0
    FaceGroupsAPI.config.FB_CLIENT_SECRET.length.must_be :>, 0
    FaceGroupsAPI.config.FB_ACCESS_TOKEN.length.must_be :>, 0
  end

  it 'should successfully find the root route' do
    get '/'
    last_response.body.must_include 'Groups'
    last_response.status.must_equal 200
  end
end
