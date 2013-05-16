module Recognition
  module ActiveRecord
    module Recognizable
      # Determine user current balance of points
      def points
        Database.get_user_points self.id
      end

      def recognition_counter bucket
        Database.get_user_counter self.id, bucket
      end

      def add_initial_points
        Database.update_points self, :initial, self.class.recognitions[:initial]
      end

      def update_points amount, bucket
        Database.log(self.id, amount.to_i, bucket)
      end
  
      def transactions page = 0, per = 20
        Database.get_user_transactions self.id, page, per
      end
    end
  end
end