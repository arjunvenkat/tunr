namespace :scrape do
  desc "Scrape You Made It Weird data"
  task :you_made_it_weird => :environment do
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

    rss = RSS::Parser.parse("http://feeds.feedburner.com/YouMadeItWeird?format=xml", false)

    ep_num = 0
    rss.items.each do |item|
      ep_num += 1
      ep_title = item.title
                        .gsub('&amp;', '&')
                        .gsub('&nbsp;', ' ')
                        .gsub('&ldquo;', '\"')
                        .gsub('&rdquo;', '\"')
                        .gsub('&rsquo;', '\'')
                        .gsub('&rsquo;', '\"')


      ep_link = item.link
      ep_date = item.pubDate.strftime("%Y-%m-%d")
      season = item.pubDate.strftime("%Y")

      ep_desc = item.description
      ep_desc =  Sanitize.clean(ep_desc)
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

      unless Podcast.find_by(name: "You Made It Weird")
        p = Podcast.new
        p.name = "You Made It Weird"
        p.desc = "Everybody has secret weirdness, Pete Holmes gets comedians to share theirs."
        p.image_url = "http://a5.mzstatic.com/us/r30/Music4/v4/a6/41/22/a6412228-2ed4-d29e-61f8-1b30d6a1bbb5/cover326x326.jpeg"
        p.save
        puts "created podcast: #{p.name}"
      end

      podcast  = Podcast.find_by(name: "You Made It Weird")

      unless podcast.episodes.where(episode_num: ep_num).present?
        e = Episode.new
        e.podcast_id = podcast.id
        e.season = season
        e.episode_num = ep_num
        e.title = ep_title
        e.desc = ep_desc
        e.duration = ep_duration
        e.published_date = ep_date
        e.url = ep_link
        e.explicit = true
        puts e.inspect
        e.save
        puts "#{ep_num} - #{ep_title} - #{ep_date} ** completed **"
      end


    end


    puts
    puts
    puts "Completed scrape of You Made It Weird"

  end
end
