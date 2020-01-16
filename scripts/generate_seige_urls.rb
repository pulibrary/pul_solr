# Generate a file of catalog-staging search result urls, 1 per line.
# Search phrases are drawn from common english words so as to be likely to
# produce results.
#
# The resulting file is intended for use in load testing with seige, see
# https://www.joedog.org/siege-manual/

NOUN_DICT = File.join(__dir__, "generate_seige_urls", "nouns.txt")
ADJ_DICT = File.join(__dir__, "generate_seige_urls", "adjectives.txt")
OUTFILE = "urls.txt"

class UrlFileGenerator
  # Specify number of lines for the file.
  # Half the lines will be randomly-generated searches; half will be
  # blank searches.
  # Siege selects randomly from the file if invoked with the -i option.
  def write_url_file(lines: 1_000_000)
    half = lines / 2
    File.open(OUTFILE, 'w') do |f|
      half.times do
        f.write generate_url
        f.write "\n"
      end
      half.times do
        f.write blank_search_url
        f.write "\n"
      end
    end
  end

  def blank_search_url
    "https://catalog-staging.princeton.edu/catalog?utf8=%E2%9C%93&search_field=all_fields&q="
  end

  def generate_url
    "https://catalog-staging.princeton.edu/catalog?utf8=%E2%9C%93&search_field=all_fields&q=#{get_random_query}"
  end

  # provide a 1 to 3 word random adjective / noun phrase, joined by `+`
  def get_random_query
    get_phrase.join("+")
  end

  def get_phrase
    adj_switch = [true, false].sample
    return get_adjective + get_nouns if adj_switch
    return get_nouns
  end

  # returns an array of 1 or 2 nouns
  def get_nouns
    n = random.rand(1..2)
    noun_dict.sample(n).map(&:chomp)
  end

  # returns an array of 1 adjective
  def get_adjective
    [adj_dict.sample.chomp]
  end

  def noun_dict
    @noun_dict ||= File.readlines(NOUN_DICT)
  end

  def adj_dict
    @adj_dict ||= File.readlines(ADJ_DICT)
  end

  def random
    @random ||= Random.new
  end
end

generator = UrlFileGenerator.new
generator.write_url_file
