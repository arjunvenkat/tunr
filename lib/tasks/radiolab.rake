namespace :scrape do
  desc "Scrape Radiolab data"
  task :radiolab => :environment do
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

    podcast = Podcast.find_by(name: "Radiolab")
    unless podcast
      podcast = Podcast.new
      podcast.name = "Radiolab"
      podcast.desc = "Radiolab is a show about curiosity. Where sound illuminates ideas, and the boundaries blur between science, philosophy, and human experience."
      podcast.image_url = "http://parmenides.wnyc.org/media/photologue/photos/RL_vert.png"
      podcast.save
    end

    url = "http://en.wikipedia.org/wiki/List_of_Radiolab_episodes"

    agent = Mechanize.new
    page = agent.get(url)
    main_tables = page.search('h2 + table')
    season = 0
    duration = 60

    main_tables.each_with_index do |table, index|
      season = index + 1
      ep_num = ""
      ep_title = ""
      ep_date = ""
      ep_link = ""
      ep_desc = ""
      table.search('tr').each_with_index do |row, index|
        unless index == 0
          if index.odd?
            ep_num = row.search('th').text
            ep_title = row.search('td:nth-of-type(1)').text
            ep_date = row.search('td:nth-of-type(2) span.published').text
            # puts "#{ep_num} - #{ep_title}  #{ep_date}"
          else
            if row.search('a')[0]
              ep_link = row.search('a')[0]['href']
              # puts "#{ep_link}"
            else
              puts 'not exist'
            end
            desc_page = agent.get(ep_link)
            ep_desc = ""
            desc_page.search('.article-description p').each_with_index do |graf, index|
              if index == 0
                ep_desc << graf.text
              else
                ep_desc << "\n\n#{graf.text}"
              end
            end
            ep_desc
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
              puts ep_date
              e.published_date = Date.parse(ep_date)
              e.url = ep_link
              e.explicit = false
              puts e.inspect
              e.save
              puts "season: #{season} ep:#{ep_num} - #{ep_title} ** completed **"
            end

            ep_num = ""
            ep_title = ""
            ep_date = ""
            ep_link = ""
            ep_desc = ""
          end
        end
      end
    end

    puts
    puts
    puts "Completed scrape of Radiolab data"



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
          e.url = ep_link
          e.explicit = false
          e.save
          puts "season: #{season} ep:#{ep_num} - #{ep_title} ** completed **"
        end
      end

    end


    puts
    puts
    puts "Completed scrape of Radiolab data"
  end
end
