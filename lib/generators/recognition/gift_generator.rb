module Recognition
  module Generators
    class GiftGenerator < ::Rails::Generators::Base
      desc "Generates a Recognition Gift"
      
      def scaffold
        generate 'scaffold gift code amount:integer reusable:boolean expires_at:datetime'
      end
      
      def set_defaults
        line = "t.boolean :reusable"
        gsub_file Dir.glob("db/migrate/*_create_gifts.rb").first, /(#{Regexp.escape(line)})/mi do |match|
          "#{match}, default: false"
        end
      end
      
      def add_stanza
        line = "class Gift < ActiveRecord::Base"
        gsub_file 'app/models/gift.rb', /(#{Regexp.escape(line)})/mi do |match|
          "#{match}\n  acts_as_gift code_length: 20 \n"
        end
      end
    end
  end
end