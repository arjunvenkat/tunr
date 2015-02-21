json.array!(@users) do |user|
  json.extract! user, :id, :username, :email, :fname, :lname, :sex, :desc, :image_url, :age_range
  json.url user_url(user, format: :json)
end
