# frozen_string_literal: true
require 'sinatra'
require 'econfig'
require 'facegroups'
require 'sequel'
require_relative 'base'
require_relative 'models/group'
require_relative 'models/posting'

# GroupsAPI web service
class FaceGroupsAPI < Sinatra::Base
  API_VER = 'api/v0.1'
  FB_GROUP_REGEX = %r{\"fb:\/\/group\/(\d+)\"}
  
  get '/?' do
    "GroupsAPI latest version endpoints are at: /#{API_VER}/"
   end

  get "/#{API_VER}/group/:id/?" do
    group_id = params[:id]
    begin
      group = Group.find(id: group_id)

      content_type 'application/json'
      { id: group.id, name: group.name }.to_json
    rescue
      content_type 'text/plain'
      halt 404, "FB Group (id: #{group_id}) not found"
    end
  end

   get "/#{API_VER}/group/:id/posting/?" do
    group_id = params[:id]
    begin
      group = Group.find(id: group_id)
      halt 400, "FB Group (id: #{group_id}) not found" unless group

      postings = {
        postings: group.postings.map do |post|
          posting = { posting_id: post.id, group_id: group_id }
          posting[:message] = post.message if post.message
          posting[:name] = post.name if post.name
          if post.attachment_title
            posting[:attachment] = {
              title: post.attachment_title,
              url: post.attachment_url,
              description: post.attachment_description
            }
          end
          { posting: posting }
        end
      }

      content_type 'application/json'
      postings.to_json
     rescue
       content_type 'text/plain'
       halt 500, "FB Group (id: #{group_id}) could not be processed"
     end
  end

  # Body args (JSON) e.g.: { "url": "http://facebook.com/groups/group_name" }
  post "/#{API_VER}/group/?" do
    begin
      body_params = JSON.parse request.body.read
      fb_group_url = body_params['url']
      fb_group_html = HTTP.get(fb_group_url).body.to_s
      fb_group_id = fb_group_html.match(FB_GROUP_REGEX)[1]

      if Group.find(fb_id: fb_group_id)
        halt 422, "Group (id: #{fb_group_id}) already exists"
      end

      fb_group = FaceGroups::Group.find(id: fb_group_id)
    rescue
      content_type 'text/plain'
      halt 400, "Group (url: #{fb_group_url}) could not be found"
    end

    begin
      group = Group.create(fb_id: fb_group.id, name:fb_group.name)

      fb_group.feed.postings.each do |fb_posting|
        Posting.create(
          group_id: group.id,
          fb_id: fb_posting.id,
          created_time: fb_posting.created_time,
          updated_time: fb_posting.updated_time,
          message: fb_posting.message,
          name: fb_posting.name,
          attachment_title: fb_posting.attachment&.title,
          attachment_description: fb_posting.attachment&.description,
          attachment_url: fb_posting.attachment&.url
        )
      end

      content_type 'application/json'
      { group_id: group.id, name: group.name }.to_json
    rescue
      content_type 'text/plain'
      halt 500, "Cannot create group (id: #{fb_group_id})"
    end
  end

  put "/#{API_VER}/posting/:id" do
    begin
      posting_id = params[:id]
      posting = Posting.find(id: posting_id)
      halt 400, "Posting (id: #{posting_id}) is not stored" unless posting
      updated_posting = FaceGroups::Posting.find(id: posting.fb_id)
      if updated_posting.nil?
        halt 404, "Posting (id: #{posting_id}) not found on Facebook"
      end

      posting.update(
        created_time: updated_posting.created_time,
        updated_time: updated_posting.updated_time,
        message: updated_posting.message,
        name: updated_posting.name,
        attachment_title: updated_posting.attachment&.title,
        attachment_description: updated_posting.attachment&.description,
        attachment_url: updated_posting.attachment&.url
      )
      posting.save

      content_type 'text/plain'
      body ''
    rescue
      content_type 'text/plain'
      halt 500, "Cannot update posting (id: #{posting_id})"
    end
  end
end
