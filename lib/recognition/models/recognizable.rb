require 'recognition/database'

module Recognition
  module Models
    module Recognizable
      # Determine user current balance of points
      def points
        recognition_counter 'points'
      end

      def recognition_counter bucket
        Recognition::Database.get_user_counter self.id, bucket
      end

      def add_initial_points
        amount = self.class.recognitions[:initial][:amount]
        update_points amount, :initial
      end

      def update_points amount, bucket
        require 'recognition/database'
        Recognition::Database.log(self.id, amount.to_i, bucket)
      end
  
      def transactions page = 0, per = 20
        start = page * per 
        stop = (1 + page) * per 
        keypart = "user:#{ self.id }"
        Recognition::Database.get_transactions keypart, start, stop
      end
    end
  end
end