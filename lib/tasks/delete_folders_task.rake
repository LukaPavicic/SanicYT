require 'fileutils'

desc 'Delete all folders that are older than five minutes every 10 minutes'

task :delete_song_folders do
    Dir.chdir('./') do
        Dir.glob('*').select { |f| 
            if File.directory?(f) && f.start_with?('songs')                
                if((Time.now.to_i - File.ctime(f + "/YourSongs.zip").to_i)/60) >= 5
                    FileUtils.rm_rf(f)
                end
            end            
        }
    end
end