namespace :scrape do
  desc "Scrape Freakonomics data"
  task :freakonomics => :environment do
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

    podcast = Podcast.find_by(name: "Freakonomics")
    unless podcast
      podcast = Podcast.new
      podcast.name = "Freakonomics"
      podcast.desc = "In their books \"Freakonomics,\" \"SuperFreakonomics,\" and \"Think Like a Freak,\" Steven D. Levitt and Stephen J. Dubner explore \"the hidden side of everything,\" telling stories about cheating schoolteachers and eating champions while teaching us all to think a bit more creatively, rationally, and productively. The Freakonomics Radio podcast, hosted by Dubner, carries on that tradition with weekly episodes. Prepare to be enlightened, engaged, perhaps enraged, and definitely surprised."
      podcast.image_url = "https://postmediavancouversun.files.wordpress.com/2011/08/freakradio.gif"
      podcast.save
    end

    agent = Mechanize.new
    url = "http://freakonomics.com/radio/freakonomics-radio-podcast-archive/"

    page = agent.get(url)

    ep_rows = page.search('table.radioarchive tr')

    ep_rows.each_with_index do |ep_row, index|
      unless index == 0
        ep_num = ep_row.search('td:nth-of-type(1)').text
        ep_title = ep_row.search('td a').text

        begin
          ep_link = ep_row.search('td a').attr('href')
        rescue
          puts "error reading link"
        end

        ep_desc = ep_row.search('td:nth-of-type(2)').text
                                                      .gsub('&amp;', '&')
                                                      .gsub('&nbsp;', ' ')
                                                      .gsub('&ldquo;', '\"')
                                                      .gsub('&rdquo;', '\"')
                                                      .gsub('&rsquo;', '\'')
                                                      .gsub('&rsquo;', '\"')
        # sanitizing title from ep_desc text
        ep_desc.slice!(ep_title)

        ep_date = ep_row.search('td:nth-of-type(3)').text
        ep_duration = ep_row.search('td:nth-of-type(4)').text.split(":")[0]


        year = ep_date.split("/")[2]
        season = "20" + year.to_s

        unless ep_num == "" || ep_num == nil
          matched_episodes = podcast.episodes.where(title: ep_title)
          unless matched_episodes.present?
            e = Episode.new
            e.podcast_id = podcast.id
            e.title = ep_title
            e.season = season
            e.episode_num = ep_num
            e.desc = ep_desc.strip
            e.duration = ep_duration
            e.published_date = Date.strptime(ep_date, "%m/%d/%y")
            e.url = ep_link
            e.explicit = false
            e.save
            puts "season: #{season} ep:#{ep_num} - #{ep_title} ** completed **"
          else
            puts "#{matched_episodes.first.title} already present in database"
          end
        end

      end
    end


    puts
    puts
    puts "Completed scrape of Freakonomics data"

  end
end
