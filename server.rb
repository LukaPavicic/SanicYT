require 'sinatra'
require 'sinatra/cross_origin'
require 'sinatra/activerecord'
require 'json'
require 'zip'
require 'rubygems'
require 'fileutils'

def download_single_song(song_name, song_list_id, is_last_song)
    formatted_command = 'youtube-dl -o "' + __dir__.to_s + '/' + song_list_id + '/%(title)s.%(ext)s" -x --audio-format mp3 "ytsearch:' + song_name + '"'
    system formatted_command

    songs_downloaded_stat = Statistic.where(name: 'songs_downloaded').first
    songs_downloaded_stat.update(value: songs_downloaded_stat.value + 1)

    return {song_name: song_name, finished: true}.to_json
end

def zip_songs(dir_name) 
    zipfile_name = "#{__dir__.to_s}/#{dir_name}/YourSongs.zip"
    folder_to_zip = "#{__dir__.to_s}/#{dir_name}"
    file_names = Dir.children(dir_name)

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
        file_names.each do |filename|
            zipfile.add(filename, File.join(folder_to_zip, filename))
        end
    end 

    return {success: true}.to_json
end

before { 
    response.headers['Access-Control-Allow-Origin'] = '*' 
}

configure do
    enable :cross_origin
end

set :allow_origin, :any
set :allow_methods, [:get, :post, :options]
set :allow_credentials, true
set :max_age, "1728000"
set :expose_headers, ['Content-Type']
set :protection, :origin_whitelist => ['http://localhost:3000']

get '/' do 
    'Welcome to SanicYT API! What are you doing here?'    
end

get '/download_songs/:folder_name' do |folder_name|
    file_to_return = "./#{folder_name}/YourSongs.zip"    
    send_file file_to_return, :filename => "YourSongs.zip", :type => 'application/octet-stream'
end

post '/initializenewdir' do
    Dir.mkdir(params['dir_name'])
end

post '/download_s' do
    content_type :json
    song_name = params['song_name']
    song_list_id = params['song_list_id']
    is_last_song = params['is_last_song']
    download_single_song(song_name, song_list_id, is_last_song)
end

post '/zipsongs' do
    zip_songs(params['dir_name'])
end

options "*" do
    response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
   
    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
   
    200
end

get '/songs_downloaded_number' do
  return {songs_downloaded: Statistic.where(name: 'songs_downloaded').first.value}.to_json
end

require './models'


