# frozen_string_literal: true

configure :development do
  def reload!
    # Tux reloading: https://github.com/cldwalker/tux/issues/3
    exec $PROGRAM_NAME, *ARGV
  end
end

# configure based on environment
class FaceGroupsAPI < Sinatra::Base
  extend Econfig::Shortcut

  API_VER = 'api/v0.1'

  configure do
    Econfig.env = settings.environment.to_s
    Econfig.root = File.expand_path('..', settings.root)
    FaceGroups::FbApi.config.update(
      client_id: config.FB_CLIENT_ID,
      client_secret: config.FB_CLIENT_SECRET
    )
  end

  after do
    content_type 'application/json'
  end

  get '/?' do
    {
      status: 'OK',
      message: "GroupsAPI latest version endpoints are at: /#{API_VER}/"
    }.to_json
  end
end
