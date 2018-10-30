require 'strava/api/v3'
require 'json'

# https://yizeng.me/2017/01/11/get-a-strava-api-access-token-with-write-permission/

class Activity

    EXPORT_DIR = "/tmp/strava_export"

    def initialize
        @client = Strava::Api::V3::Client.new(:access_token => ENV["access_token"])
    end

    def create_activities
        Dir.glob("#{EXPORT_DIR}/*.json").each do |f|
            data = JSON.parse(File.read(f))
            activity = build_activity(data)
            if activity
                puts activity
                @client.create_an_activity(activity)
            else
                puts "Not a running activity"
            end
        end

    end

    private

    def build_activity(data)
        return nil unless (data["activityType"]["internalName"]) == "Running"
        { name: data["title"], 
                description: data["description"],
                type: 'run',
                start_date_local: data["startTime"]["time"],
                elapsed_time: data["elapsedTime"].to_i,
                distance: data["distance"] }
    end

end


if __FILE__ == $0

    Activity.new.create_activities

end
