json.array!(@podcasts) do |podcast|
  json.extract! podcast, :id, :name, :published_by, :desc, :update_freq, :update_day, :image_url, :host, :created_by
  json.url podcast_url(podcast, format: :json)
end
