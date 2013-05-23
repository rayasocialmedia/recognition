module Recognition
  module Generators
    class VoucherGenerator < Rails::Generators::Base
      def scaffold
        generate 'scaffold voucher code amount:integer reusable:boolean expires_at:datetime'
      end
      
      def set_defaults
        line = "t.boolean :reusable"
        gsub_file Dir.glob("db/migrate/*_create_vouchers.rb").first, /(#{Regexp.escape(line)})/mi do |match|
          "#{match}, default: false"
        end
      end
      
      def add_stanza
        line = "class Voucher < ActiveRecord::Base"
        gsub_file 'app/models/voucher.rb', /(#{Regexp.escape(line)})/mi do |match|
          "#{match}\n  acts_as_voucher code_length: 20 \n"
        end
      end
    end
  end
end