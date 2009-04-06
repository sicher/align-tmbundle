#!/usr/bin/env ruby
#
#  tm_align.rb
#  
#  By Mikael Säker. All rights reserved.
# 

# TODO: convert ALL tabs to spaces, not just indents...

require ENV['TM_SUPPORT_PATH'] + '/lib/textmate'
require ENV['TM_SUPPORT_PATH'] + '/lib/ui'

module Align
  
  def expand_tabs(str)
    ts = ENV["TM_TAB_SIZE"].to_i
    str.gsub(/([^\t]{#{ts}})|([^\t]*)\t/n){[$+].pack("A#{ts}")}
  end

  def empty?(str)
    if str.strip.length == 0 then
      return true
    end
    return false
  end

  def find_block_start(lines, currentline)
    # If current line is empty...
    if empty?(lines[currentline]) then
      return currentline
    end
    # Figure out the indent on the current line
    block_indent = lines[currentline].index(/\S/).to_i
    startline = currentline
    # Look backwards until beginning of this block...
    (currentline - 1).downto(0) do |i|
      line_indent = expand_tabs(lines[i]).index(/\S/).to_i
      if line_indent != block_indent || empty?(lines[i]) then
        return i + 1
      end
      startline -= 1
    end
    return startline
  end

  def find_block_end(lines, currentline)
    # If current line is empty...
    if empty?(lines[currentline]) then
      return currentline
    end
    # Figure out the indent on the current line
    block_indent = expand_tabs(lines[currentline]).index(/\S/).to_i
    # Look backwards until beginning of this block...
    endline = currentline
    (currentline + 1).upto(lines.length - 1) do |i|
      line_indent = expand_tabs(lines[i]).index(/\S/).to_i
      if line_indent != block_indent || empty?(lines[i]) then
        return i - 1
      end
      endline += 1
    end
    return endline
  end

  # Return an array containing one array for each line in the range which in turn containst
  # the widths between each ocurrence of the pattern matches. Whitespace is not counted.
  def rangefieldwidths(range, p, includemathinglines)
    rangefieldwidths = Array.new
    range.each do |l|
      if !includemathinglines and !p.match(l) then
        next
      end  
      linefieldwidths = Array.new
      l.split(p).each do |s|
        linefieldwidths.push(s.strip.length)
      end
      rangefieldwidths.push(linefieldwidths)
    end
    return rangefieldwidths
  end

  def patternregexp(pattern)
    np = pattern.split(/\s+/).collect do |p|
      Regexp.escape(p).gsub(/\\\\/, '\\')
    end.join("|")
    return Regexp.new(np)
  end

  def numcolumns(rangefieldwidths)
    max = 0
    rangefieldwidths.each do |r|
      if r.length > max
        max = r.length
      end
    end
    return max
  end

  def widestfieldincolumn(rangefieldwidths, column)
    max = 0
    rangefieldwidths.each do |r|
      if !r[column].nil? then
        if r[column] > max then
          max = r[column]
        end      
      end
    end
    return max
  end

  def targetfieldwidths(rangefieldwidths)
    tfw = Array.new 
    0.upto(numcolumns(rangefieldwidths) - 1) do |c|
      tfw.push(widestfieldincolumn(rangefieldwidths, c))
    end
    return tfw
  end

  def widestseparator(range, p)
    max = 0;
    range.each do |l|
      i = 0
      l.split(p).each do |s|
        i += s.length
        sep = l.slice(i, l.length).slice(p)
        if sep then
          if sep.length > max then
            max = sep.length
          end 
          i += sep.length
        end
      end
    end
    return max
  end

  def reformatrange(range, patterns, options)
    p = patternregexp(patterns)
    rangefieldwidths = rangefieldwidths(range, p, options[:include_non_matching_lines])  
    tfw = targetfieldwidths(rangefieldwidths)
    firstline_indent = nil
    if options[:right_justify_separators] then
      wsep = widestseparator(range, p)
    end
    if @pre_selection then
      puts @pre_selection
    end
    range.each do |l|
      if !options[:include_non_matching_lines] and !p.match(l) then
        puts l
        next
      end
      c = 0
      i = 0
      currentline_indent = expand_tabs(l).index(/\S/).to_i
      if !firstline_indent then
        firstline_indent = currentline_indent
      end
      
      # Print indentation...
      if options[:indent_as_first_line] then
        $stdout.write " " * firstline_indent
      else
        $stdout.write " " * currentline_indent
      end
            
      l.split(p).each do |s|
        i += s.length
        sep = l.slice(i, l.length).slice(p)

        # Deal with the field and field right hand whitespace
        field = ""
        fieldws = ""
        if s.strip.length > 0 then
          if options[:right_field_whitespace] then
            fieldws = " "
          end
          if options[:right_justify_fields] then
            field = "#{s.strip.rjust(tfw[c])}"
          elsif !sep then
            # no ws before newline
            field = "#{s.strip}"
            fieldws = ""
          else
            field = "#{s.strip.ljust(tfw[c])}"
          end
        end

        separator = ""
        separatorws = ""
        if sep then
          if options[:right_justify_separators] then
            separator = "#{sep.rjust(wsep)}"
          else
            separator = sep
          end        
          if options[:right_separator_whitespace] then
            separatorws = " "
          end
          i += sep.length
          
          # no ws before newline
          if l.slice(i, l.length).strip == "" then
            separatorws = ""
          end
        end
        
        # Print it!
        $stdout.write "#{field}#{fieldws}#{separator}#{separatorws}"
        c += 1
      end
      # Newline
      puts
    end
    if @post_selection then
      puts @post_selection
    end
  end

  def get_selection
    lines = STDIN.readlines()
    selection = Array.new
    selection_done = ENV.member?("TM_SELECTED_TEXT")

    # Depending if user has no selection, we need to create the selection
    if !selection_done then
      @pre_selection = Array.new
      @post_selection = Array.new    
      current_lineno = ENV["TM_LINE_NUMBER"].to_i - 1
      # Fix trailing newline which causes a "nil" last line
      if lines[current_lineno].nil? then
        lines[current_lineno] = ""
      end
      blockstart = find_block_start(lines, current_lineno)
      blockend = find_block_end(lines, current_lineno)
      
      # Store pre- and post selection
      0.upto(blockstart - 1) do |i|
        @pre_selection.push(lines[i])
      end 
      (blockend + 1).upto(lines.length - 1) do |i|
        @post_selection.push(lines[i])
      end 
      
      blockstart.upto(blockend) do |i|
        selection.push(lines[i])
      end
    else
      @pre_selection  = nil
      @post_selection = nil
      selection       = lines
    end
    return selection.map do |l|
      expand_tabs(l)
    end
  end

  def request_patterns(default)
    options           = Hash.new
    options[:title]   = "Align Selection"
    options[:prompt]  = "Enter alignment anchor pattern(s):"
    options[:default] = default
    return TextMate::UI.request_string(options)  
  end
  
  extend self
end

############################################################################
