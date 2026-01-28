module EventEngine
  module Dashboard
    class BaseController < ApplicationController
      before_action :authenticate_dashboard!

      private

      def authenticate_dashboard!
        auth = EventEngine.configuration.dashboard_auth

        unless auth && auth.call(self)
          render plain: "Forbidden", status: :forbidden
        end
      end
    end
  end
end
