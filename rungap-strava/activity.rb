require 'strava/api/v3'
require 'json'

# https://yizeng.me/2017/01/11/get-a-strava-api-access-token-with-write-permission/

class Activity

    EXPORT_DIR = "#{Dir.home}/Dropbox/Apps/RunGap/export"
    WORKING_DIR = "/tmp/strava_export"
    SUPPORTED_TYPES = ["Run"]
    TYPE_MAP = {"Running" => "Run", "Cycling" => "Ride"}

    def initialize
        @client = Strava::Api::V3::Client.new(:access_token => ENV["access_token"])
    end

    def create_activities
        return unless init
        Dir.glob("#{WORKING_DIR}/*.json").each do |f|
            data = JSON.parse(File.read(f))
            activity = build_activity(data)
            @client.create_an_activity(activity) if SUPPORTED_TYPES.include? activity[:type]
        end
    end

    def init      
        Dir.chdir(EXPORT_DIR) do
            exported_files = Dir.glob("*.zip")
            puts "Found #{exported_files.size} exported file(s)"
            return false if exported_files.size == 0
            `rm -rf #{WORKING_DIR} && mkdir #{WORKING_DIR}`
            `unzip -o '*.zip' -d #{WORKING_DIR}`
        end
        true
    end

    private

    def build_activity(data)
        activity_type = data["activityType"]["internalName"]
        { name: data["title"], 
                description: data["description"],
                type: TYPE_MAP[activity_type],
                start_date_local: data["startTime"]["time"],
                elapsed_time: data["elapsedTime"].to_i,
                distance: data["distance"] }
    end

end


if __FILE__ == $0
    
    Activity.new.create_activities

end
