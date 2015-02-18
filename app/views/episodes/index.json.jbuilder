json.array!(@episodes) do |episode|
  json.extract! episode, :id, :podcast_id, :season, :episode_num, :title, :desc, :duration, :published_date, :url, :explicit
  json.url episode_url(episode, format: :json)
end
