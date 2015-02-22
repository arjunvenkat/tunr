json.array!(@upvotes) do |upvote|
  json.extract! upvote, :id, :user_id, :review_id
  json.url upvote_url(upvote, format: :json)
end
