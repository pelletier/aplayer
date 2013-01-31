require 'find'
require 'id3lib'
require 'iconv'

require "#{Rails.root.to_s}/app/models/song.rb"

namespace :songs do
  desc "Import songs from hard drive"
  task :import => :environment do
    path = "/Users/thomas/Music/iTunes/iTunes Media/Music"
    Find.find(path) do |f|
      next if not f.match(/\.mp3\Z/)
      url = "http://localhost:6650#{f.to_s()[path.length..-1]}"
      tag = ID3Lib::Tag.new(f)
      if tag.title.blank? or tag.artist.blank?
        next
      end
      title = Iconv.iconv('utf-8', 'iso8859-1', tag.title).first
      artist = Iconv.iconv('utf-8', 'iso8859-1', tag.artist).first
      puts "#{title} - #{artist}"
      Song.new(url: url, name: title, artist: artist).save
    end
  end
end
