require "json"
require "anki"
require "net/http"
require "uri"
require "optparse"

class CommandExecutor
  def initialize
    @options = {}
    @data = {}
  end

  def download_images
    open_json_file
    i = 1
    data.cards.each do |card|
      if card.battlegrounds.hero || !card.minionTypeId
        i -= 1 if i > 1
        next
      end
      pp card
      pp card.name
      url = card.battlegrounds.image
      # Download image from url and save it to disk
      download_image(url, "./images_source/bg-#{i}.png")
      sleep 0.2
      i += 1
    end
  end

  def update_images
    `ffmpeg -y -i 'images_source/bg-%d.png' -vf "drawbox=x=0:y=270:w=404:h=50:c=black@1:t=fill" -pix_fmt rgba 'images_updated/bg-%d-updated.png'`
  end

  def create_deck
    `python generate_deck.py`
  end

  def run
    OptionParser.new do |opts|
      opts.banner = "Usage: script.rb [options]"
      opts.on("--download-images", "Download images") { @options[:download_images] = true }
      opts.on("--update-images", "Update images") { @options[:update_images] = true }
      opts.on("--create-deck", "Create deck") { @options[:create_deck] = true }
    end.parse!
    
    download_images if @options[:download_images]
    update_images if @options[:update_images]
    create_deck if @options[:create_deck]
  end

  private

  attr_accessor :data

  # Download an image from a URL and save it to a local file
  def download_image(url, filename)
    # Parse the URL
    uri = URI.parse(url)
    
    # Fetch the image data using Net::HTTP
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == "https"
    image_data = http.get(uri.path).body
    
    # Save the image data to a local file
    File.open(filename, "wb") do |file|
      file.write(image_data)
    end
  end

  # Open local cards db
  def open_json_file
    file = File.read('./cards-1.json')
    @data = JSON.parse(file, object_class: OpenStruct)
  end
end

executor = CommandExecutor.new
executor.run
