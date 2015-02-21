json.array!(@reviews) do |review|
  json.extract! review, :id, :user_id, :episode_id, :rating, :contents
  json.url review_url(review, format: :json)
end
