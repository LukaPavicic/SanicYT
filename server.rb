require 'sinatra'
require 'sinatra/cross_origin'
require 'json'
require 'zip'
require 'rubygems'
require 'fileutils'
require 'youtube-dl.rb'

def download_songs(song_list)    
    time = Time.new
    temp_dir_name = "songs" + rand(100000..999999).to_s + time.strftime("%d%m%Y%H%M%S")
    Dir.mkdir(temp_dir_name)
    song_list.each { |song|
        # formatted_command = 'youtube-dl -o "' + __dir__.to_s + '/' + temp_dir_name + '/%(title)s.%(ext)s" -x --audio-format mp3 "ytsearch:' + song + '"'
        # system formatted_command
        options = {
            # audio_format: :mp3,
            extract_audio: true,
            output: "#{__dir__.to_s}/#{temp_dir_name}/%(title)s.%(ext)s",
        }
        YoutubeDL.download "ytsearch:#{song}", options
    }

    zipfile_name = "#{__dir__.to_s}/#{temp_dir_name}/YourSongs.zip"
    folder_to_zip = "#{__dir__.to_s}/#{temp_dir_name}"
    file_names = Dir.children(temp_dir_name)

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
        file_names.each do |filename|
            zipfile.add(filename, File.join(folder_to_zip, filename))
        end
    end    

    return {songs_id: temp_dir_name}.to_json
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
    'Henlo!'    
end

get '/download_songs/:folder_name' do |folder_name|
    file_to_return = "./#{folder_name}/YourSongs.zip"    
    send_file file_to_return, :filename => "YourSongs.zip", :type => 'application/octet-stream'
end

post '/download' do
    content_type :json
    all_songs_to_download = params['songs'].split(',')
    download_songs(all_songs_to_download)        
end

options "*" do
    response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
   
    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
   
    200
end




