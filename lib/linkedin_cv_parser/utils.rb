require 'date'

# -*- encoding : utf-8 -*-
class LinkedinCvParser
  class Utils
    class << self
      def header?(line)
        Schema.headers.include?(line) || line.include?('Profile Notes and Activity') || recommendation?(line)
      end

      def recommendation?(line)
        line.include?('person has recommended') || line.include?('people have recommended')
      end


      def degree_line?(line)
        trigger_word  = %w{ MBA Master BS Diploma Bachelor CEMS }.any? { |degree| line.include? degree }
        year_format_1 = !!(line =~ /(\d{4}-\d{4})/)
        year_format_2 = !!(line =~ /(\d{4} - \d{4})/)

        (trigger_word || year_format_1 || year_format_2)
      end

      def skip_line?(line)
        trigger_word = ['Activites and Societies'].any? { |degree| line.include? degree }
        watermark    = !!(line =~ /^Contact [\w]+ on LinkedIn$/)

        (trigger_word || watermark)
      end

      def duration?(line)
        recruiter_version = !!(line =~ /((((\w*\s)*\d+) - ((\w*\s)*\d+)) \(([^\)]+)\))|(((\w+ \d+) - (Present)) \(([^\)]+)\))/)
        user_version = !!(line =~ /((((\w*\s)*\d+) - (Present)))/)
        recruiter_version || user_version
      end

      def page_number?(line)
        (line == 'Page') || (Float(line) != nil rescue false) || !!(line =~ /Page \d/)
      end

      def parse_date(value, end_of_year: false)
        begin
          if value.downcase == 'present'
            DateTime.now
          else
            strptime(value, end_of_year)
          end
        rescue
          nil
        end
      end

      private

      def strptime(value, end_of_year)
        DateTime.strptime(value, '%B %Y')
      rescue
        d = Date.strptime(value, '%Y')
        d = d.next_year.prev_day if end_of_year
        d
      end
    end
  end
end
