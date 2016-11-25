# frozen_string_literal: true

# Posting routes
class FaceGroupsAPI < Sinatra::Base
  get "/#{API_VER}/group/:id/posting/?" do
    results = SearchPostings.call(params)

    if results.success?
      PostingsSearchResultsRepresenter.new(results.value).to_json
    else
      ErrorRepresenter.new(results.value).to_status_response
    end
  end

  put "/#{API_VER}/posting/:id" do
    result = UpdatePostingFromFB.call(params)

    if result.success?
      PostingRepresenter.new(result.value).to_json
    else
      ErrorRepresenter.new(result.value).to_status_response
    end
  end
end