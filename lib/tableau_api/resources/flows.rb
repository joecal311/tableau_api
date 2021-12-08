module TableauApi
  module Resources
    class Flows < Base
      def list
        url = "sites/#{@client.auth.site_id}/flows"
        @client.connection.api_get_collection(url, 'flows.flow')
      end

      def run(flow_id)
        request = Builder::XmlMarkup.new.tsRequest do |ts|
        end

        res = @client.connection.api_post("sites/#{@client.auth.site_id}/flows/#{flow_id}/run", body: request)

        res.code == 200
      end
    end
  end
end
