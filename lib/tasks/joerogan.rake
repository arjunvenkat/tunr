namespace :scrape do
  desc "Scrape Joe Rogan Experience data"
  task :joerogan => :environment do
    require 'rss'
    require 'mechanize'
    require 'open-uri'
    require 'csv'
    require "net/http"
    # require "Sanitize"
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


    # CSV.open("joe_rogan.csv", "wb") do |csv|
    #   csv << ["index","season", "episode_num", "rebroadcast","title", "description", "duration", "published_date", "url", "explicit"]
    # end
    agent = Mechanize.new



    rss = RSS::Parser.parse("http://joeroganexp.joerogan.libsynpro.com/rss", false)

    rss.items.each do |item|
      title = item.title

      if title.include? "#"
        ep_num = title.split(" - ")[0]
        ep_num = ep_num.split("#")[1]
        ep_title = title.split(" - ")[1]

      else
        ep_num = ""
        ep_title = title
      end

      if ep_title != nil
      ep_title = ep_title.encode('utf-8', :fallback => fallback)
      end

      ep_link = item.enclosure.url
      ep_date = item.pubDate.strftime("%Y-%m-%d")
      season = item.pubDate.strftime("%Y")


      ep_desc = item.description
      # ep_desc =  Sanitize.clean(ep_desc)
      ep_desc =  ep_desc.encode('utf-8', :fallback => fallback)
                            .gsub('&amp;', '&')
                            .gsub('&nbsp;', ' ')
                            .gsub('&ldquo;', '\"')
                            .gsub('&rdquo;', '\"')
                            .gsub('&rsquo;', '\'')
                            .gsub('&rsquo;', '\"')

       if defined? item.itunes_duration.content
        ep_duration = item.itunes_duration.content
      else
        ep_duration = ""
      end


      podcast  = Podcast.find_by(name: "The Joe Rogan Experience")
      e = Episode.new
      e.podcast_id = podcast.id
      e.season = season
      e.episode_num = ep_num
      e.title = ep_title
      e.desc = ep_desc
      e.duration = 20
      e.published_date = ep_date
      e.url = ep_link
      e.explicit = false
      e.save

      # CSV.open("joe_rogan.csv", "a+") do |csv|
      #   csv << [ep_num,season, ep_num, "N",ep_title, ep_desc, ep_duration, ep_date, ep_link, "Y"]
      # end
      puts "#{ep_num} - #{ep_title} - #{ep_date} ** completed **"

    end


    puts
    puts
    puts "Completed scrape of Joe Rogan"

  end
end
