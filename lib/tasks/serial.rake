namespace :scrape do
  desc "Scrape Serial data"
  task :serial => :environment do
    require 'rss'
    require 'mechanize'
    require 'open-uri'
    require 'csv'
    require "net/http"
    require "sanitize"
    require 'date'


     fallback = {
            'Š'=>'S', 'š'=>'s', 'Ð'=>'Dj','Ž'=>'Z', 'ž'=>'z', 'À'=>'A', 'Á'=>'A', 'Â'=>'A', 'Ã'=>'A', 'Ä'=>'A',
            'Å'=>'A', 'Æ'=>'A', 'Ç'=>'C', 'È'=>'E', 'É'=>'E', 'Ê'=>'E', 'Ë'=>'E', 'Ì'=>'I', 'Í'=>'I', 'Î'=>'I',
            'Ï'=>'I', 'Ñ'=>'N', 'Ò'=>'O', 'Ó'=>'O', 'Ô'=>'O', 'Õ'=>'O', 'Ö'=>'O', 'Ø'=>'O', 'Ù'=>'U', 'Ú'=>'U',
            'Û'=>'U', 'Ü'=>'U', 'Ý'=>'Y', 'Þ'=>'B', 'ß'=>'Ss','à'=>'a', 'á'=>'a', 'â'=>'a', 'ã'=>'a', 'ä'=>'a',
            'å'=>'a', 'æ'=>'a', 'ç'=>'c', 'è'=>'e', 'é'=>'e', 'ê'=>'e', 'ë'=>'e', 'ì'=>'i', 'í'=>'i', 'î'=>'i',
            'ï'=>'i', 'ð'=>'o', 'ñ'=>'n', 'ò'=>'o', 'ó'=>'o', 'ô'=>'o', 'õ'=>'o', 'ö'=>'o', 'ø'=>'o', 'ù'=>'u',
            'ú'=>'u', 'û'=>'u', 'ý'=>'y', 'þ'=>'b', 'ÿ'=>'y', 'ƒ'=>'f', '’' => '', '…' => '...', '”' => '"',
            '“' => '"', '—' => '-'
          }


    agent = Mechanize.new


    rss = RSS::Parser.parse("http://feeds.serialpodcast.org/serialpodcast?format=xml", false)

    rss.items.each do |item|
      title = item.title
      ep_num = title.split(": ")[0].split(" ")[1]
      ep_title = title.split(": ")[1]
                          .gsub('&amp;', '&')
                          .gsub('&nbsp;', ' ')
                          .gsub('&ldquo;', '\"')
                          .gsub('&rdquo;', '\"')
                          .gsub('&rsquo;', '\'')
                          .gsub('&rsquo;', '\"')
      ep_link = item.enclosure.url
      ep_date = item.pubDate
      ep_desc = item.description
                        .gsub('&amp;', '&')
                        .gsub('&nbsp;', ' ')
                        .gsub('&ldquo;', '\"')
                        .gsub('&rdquo;', '\"')
                        .gsub('&rsquo;', '\'')
                        .gsub('&rsquo;', '\"')

      if defined? item.itunes_duration.content
        duration_array = item.itunes_duration.content.split(":")
        ep_duration = (duration_array[0].to_i*60) + duration_array[2].to_i
      else
        ep_duration = ""
      end



      podcast = Podcast.find_by(name: "Serial")
      unless podcast
        podcast = Podcast.new
        podcast.name = "Serial"
        podcast.desc = "Serial is a podcast from the creators of This American Life, and is hosted by Sarah Koenig. Serial tells one story - a true story - over the course of an entire season. Each season, we'll follow a plot and characters wherever they take us. And we won’t know what happens at the end until we get there, not long before you get there with us. Each week we bring you the next chapter in the story, so it's important to listen to the episodes in order, starting with Episode 1."
        podcast.image_url = "http://mark.gg/assets/images/posts/2014-12-08/serial-logo.png"
        podcast.save
        puts "created podcast: #{podcast.name}"
      end

      unless podcast.episodes.where(episode_num: ep_num).present?
        e = Episode.new
        e.podcast_id = podcast.id
        e.published_date = ep_date
        e.season = 1
        e.episode_num = ep_num
        e.title = ep_title
        e.desc = ep_desc
        e.duration = ep_duration
        e.url = ep_link
        e.explicit = true
        e.save

        puts "#{ep_num} - #{ep_title} - #{ep_date} ** completed **"
      end

    end

    podcast = Podcast.find_by(name: "Serial")
    puts
    puts
    puts "Completed scrape of Serial data"
    puts "#{podcast.episodes.count} episodes exist for #{podcast.name}"

  end
end
