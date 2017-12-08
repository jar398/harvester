require 'csv'
# Generalized access to character-separated files. Handles more than just commas; the name is based on the CSV class it
# is derived from.
class CsvParser

  attr_accessor :diff, :path_to_file

  def initialize(path_to_file, options = {})
    @header_lines = options[:header_lines] || 1
    @data_begins_on_line = options[:data_begins_on_line] || 1
    @col_sep = options[:field_sep] || ','
    @row_sep = options[:line_sep] || "\n"
    @path_to_file = path_to_file
    @headers = nil
  end

  def line_at_a_time
    i = 0
    return false unless File.exist?(@path_to_file)
    quote = '"'
    quote = "\x00" if @col_sep == "\t" # Turns out they like to use "naked" quotes in tab-delimited files.
    begin
      CSV.foreach(@path_to_file, col_sep: @col_sep, row_sep: @row_sep, quote_char: quote, encoding: 'ISO-8859-1') do |row|
        yield(row, i)
        i += 1
      end
    rescue CSV::MalformedCSVError
      # Try again without the row sep, which can cause problems:
      CSV.foreach(@path_to_file, col_sep: @col_sep, quote_char: quote, encoding: 'ISO-8859-1') do |row|
        yield(row, i)
        i += 1
      end
    rescue => e
      raise(e.class.new(e.message + " IN +#{i} #{@path_to_file}"))
    end
    true
  end

  def headers
    return @headers if @headers
    headers = []
    offset = 0
    line_at_a_time do |row, i|
      if row.size == 1
        offset += 1
        next
      end
      break if i >= (@header_lines + offset)
      row.each_with_index do |cell, j|
        headers[j] ||= []
        headers[j] << cell.tr("\r", ' ').tr("\n", ' ')
      end
    end
    @headers = []
    headers.each do |contents|
      @headers << contents.join(' ').
                  # Fix spaces:
                  sub(/^\s+/, '').sub(/\s+$/, '').gsub(/\s+/, ' ')
    end
    @headers
  end

  def rows_as_hashes
    offset = 0
    hash = nil
    line_at_a_time do |row, i|
      offset += 1 if row.size == 1 && hash.nil?
      next if i < (@data_begins_on_line + offset)
      hash = Hash[headers.zip(row)]
      yield(hash, i)
    end
  end

  # TODO: parsing with diffs deserves its own class, move!
  def diff_as_hashes(db_headers)
    @line_num = 0
    @diff = nil
    any_diff = line_at_a_time do |row, line|
      # NOTE that this is a diff... so ... not great... but it IS the line of the file we're reading!
      @line_num = line + 1
      if row.size == 1 && row.first =~ /^\d+(\D)(\d+)?$/
        @diff = diff_type(Regexp.last_match(1))
        next
      end
      debugger if row.first.nil?
      next if ignore_row?(row.first, row.size)
      yield(row_as_diff(row, db_headers))
    end
    any_diff
  end

  def diff_type(type)
    case type
    when 'a'
      :new
    when 'c'
      :changed
    when 'd'
      :removed
    end
  end

  def line_num(new_line)
    new_line.to_i if new_line
  end

  def ignore_row?(first, size)
    # "Removed" part of a change, we can ignore it:
    (@diff == :changed && first =~ /^</) ||
      # "switch" part of a change, ignore:
      (@diff == :changed && size == 1 && first =~ /^---/) ||
      # End of input (for "faked" new diffs):
      (size == 1 && first == '.')
  end

  def row_as_diff(row, headers)
    if @diff == :changed || @diff == :new
      row.first.sub!(/^> /, '')
    elsif @diff == :removed
      row.first.sub!(/^< /, '')
    end
    Hash[headers.zip(row)]
  end
end
