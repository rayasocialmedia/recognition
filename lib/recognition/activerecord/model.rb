module Recognition
  module ActiveRecord
    module Model
      def recognize_creating
        if self.id_changed? # Unless we are creating
          Database.update_points self, :create, self.class.recognitions[:create] unless self.class.recognitions[:create].nil?
        end
      end

      def recognize_updating
        unless self.id_changed? # Unless we are creating
          Database.update_points self, :update, self.class.recognitions[:update] unless self.class.recognitions[:update].nil?
        end
      end

      def recognize_destroying
        Database.update_points self, :destroy, self.class.recognitions[:destroy] unless self.class.recognitions[:destroy].nil?
      end
    end
  end
end