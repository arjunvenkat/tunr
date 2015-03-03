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

    url = "http://www.radiolab.org/series/podcasts/"

    agent = Mechanize.new
    page = agent.get(url)
    link = page.search('.pagefooter-next a')
    while link.present?
      # current page
      page.search('.episode-tease').each do |teaser|
        title_link = teaser.search('h2.title a')
        ep_title = title_link.text
        ep_link = title_link.attr('href')
        ep_date = teaser.search('h3.date').text
        ep_page = agent.get(ep_link)
        season = ep_page.search('div.seanum-epnum')
                                    .text
                                    .split('|')[0]
                                    .strip
        season.slice!("Season ")

        # ep nums are repeated throughout each season
        ep_num = ""
        ep_desc = ""
        ep_page.search('.article-description').each do |desc_graf|
          ep_desc << desc_graf.text
        end
        ep_desc.gsub('&amp;', '&')
                .gsub('&nbsp;', ' ')
                .gsub('&ldquo;', '\"')
                .gsub('&rdquo;', '\"')
                .gsub('&rsquo;', '\'')
                .gsub('&rsquo;', '\'')

          matched_episodes = podcast.episodes.where(title: ep_title)
          unless matched_episodes.present?
            e = Episode.new
            e.podcast_id = podcast.id
            e.title = ep_title
            e.season = season
            e.episode_num = ep_num
            e.desc = ep_desc.strip
            e.duration = 60
            e.published_date = Date.parse(ep_date)
            e.url = ep_link
            e.explicit = false
            e.save
            puts "season: #{season} ep:#{ep_num} - #{ep_title} ** completed **"
          else
            puts "#{matched_episodes.first.title} already present in database"
          end


      end

      # setting up next page
      partial_link = page.search('.pagefooter-next a')
      if partial_link.present?
        next_page_num = partial_link.attr('href').text.split('/')[1]
        link = "http://www.radiolab.org/series/podcasts/#{next_page_num}"
        page = agent.get(link)
      else
        link = nil
      end
    end


    podcast.episodes.order('published_date ASC').each_with_index do |ep, index|
      ep.episode_num = index + 1
      ep.save
    end




    puts
    puts
    puts "Completed scrape of Radiolab data"
  end
end
