namespace :scrape do
  desc "Scrape This American Life data"
  task :tal => :environment do
    require 'mechanize'
    require 'open-uri'


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

    podcast = Podcast.find_by(name: "This American Life")
    unless podcast
      podcast = Podcast.new
      podcast.name = "This American Life"
      podcast.desc = "This American Life is a weekly public radio show broadcast on more than 500 stations to about 2.2 million listeners. There's a theme to each episode of This American Life, and a variety of stories on that theme. It's mostly true stories of everyday people, though not always. There's lots more to the show, but it's sort of hard to describe. Probably the best way to understand the show is to start at our favorites page, though we do have longer guides to our radio show and our TV show. If you want to dive into the hundreds of episodes we've done over the years, there's an archive of all our old radio shows and listings for all our TV episodes, too."
      podcast.image_url = "http://upload.wikimedia.org/wikipedia/commons/thumb/c/cc/This_American_Life_logo.svg/252px-This_American_Life_logo.svg.png"
      podcast.save
    end

    agent = Mechanize.new
    url = "http://www.thisamericanlife.org/radio-archives"
    main_page = agent.get(url)

    season_links = main_page.search('#archive-date-nav li a')
    season_links.each do |season_link|
      season = season_link.text
      full_season_link = "http://www.thisamericanlife.org#{ season_link.attr('href') }"
      season_page = agent.get(full_season_link)
      ep_links = season_page.search('#archive-episodes li h3 a')
      ep_links.each do |ep_link|
        full_ep_link = "http://www.thisamericanlife.org#{ep_link.attr('href')}"
        ep_page = agent.get(full_ep_link)
        split_heading = ep_page.search('h1').text.split(':')
        ep_num = split_heading[0].strip
        ep_title = split_heading[1].strip
        ep_date = ep_page.search('.top-inner .date').text
        ep_desc = ep_page.search('.description').text
                                              .strip
                                              .gsub('&amp;', '&')
                                              .gsub('&nbsp;', ' ')
                                              .gsub('&ldquo;', '\"')
                                              .gsub('&rdquo;', '\"')
                                              .gsub('&rsquo;', '\'')
                                              .gsub('&rsquo;', '\'')

        unless podcast.episodes.where(episode_num: ep_num).present?
          e = Episode.new
          e.podcast_id = podcast.id
          e.title = ep_title
          e.season = season
          e.episode_num = ep_num
          e.desc = ep_desc
          e.duration = 60
          e.published_date = Date.parse(ep_date)
          e.url = full_ep_link
          e.explicit = false
          e.save
          puts "season: #{season} ep:#{ep_num} - #{ep_title} ** completed **"
        end
      end

    end


    puts
    puts
    puts "Completed scrape of This American Life data"
  end
end
