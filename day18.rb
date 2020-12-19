require './helper.rb'
require 'optparse'

options = {}
OptionParser.new do |opt|
  opt.on('--input INPUT') { |o| options[:input] = o }
end.parse!

include Helper
input = options[:input] || "#{__FILE__}".gsub(/\.rb/, ".input")

data = get_data(input).map(&:strip)

class Calculator
  def initialize
    @buffer = nil
    @operator_buffer = nil
  end

  def calculate formula
    @buffer = nil
    @operator_buffer = nil
    @read_buffer = ''
    clause_buffer = ''

    @abc = 0

    chars = formula.chars
    index = 0
    while index < chars.length
      c = chars[index]
      case c
      when ' '
        if (@read_buffer || '') != ''
          got_operand @read_buffer.to_i 
          @read_buffer = ''
        end
      when '('
        clause_buffer = ''
        @abc +=1
        clause_buffer += c
        index+=1
        while index < chars.length && @abc > 0
          clause_buffer += chars[index]
          @abc +=1 if chars[index] == "("
          @abc -=1 if chars[index] == ")"
          index +=1
        end
        calc = Calculator.new
        got_operand calc.calculate clause_buffer[1..-2]
      when '+', "*"
        @operator_buffer = c
      else
        @read_buffer += c
      end

      index +=1
    end

    if (@read_buffer || '') != ''
      got_operand @read_buffer.to_i 
      @read_buffer = ''
    end

    #puts "#{formula} == #{@buffer}"
    @buffer
  end

  def got_operand operand
    if @buffer.nil?
      @buffer = operand
    else
      @buffer = @buffer.public_send(@operator_buffer, operand)
      
    end
  end
end

c = Calculator.new
puts data.map {|f|
  c.calculate f
}.sum

class CalculatorB
  def initialize
    @buffer = nil
    @operator_buffer = nil
  end

  def calculate formula
    parts = parse formula

    after_first_pass = []
    while parts.length > 0
      p = parts.shift
      case p
      when "*",  Integer, Array
        after_first_pass.push p
      when "+"
        operand1 = after_first_pass.pop
        after_first_pass.push(operand1+parts.shift)
      end
    end

    buffer = 0
    operand = nil
    while after_first_pass.length > 0
      p = after_first_pass.shift
      case p
      when Integer
        buffer = p
      when "*"
        buffer = buffer * after_first_pass.shift
      end

    end

    buffer
  end

  def parse formula
    buffer = []
    read_buffer = ''
    clause_buffer = ''

    abc = 0

    chars = formula.chars
    index = 0
    while index < chars.length
      c = chars[index]
      case c
      when ' '
        if (read_buffer || '') != ''
          buffer.push read_buffer.to_i
          read_buffer = ''
        end
      when '('
        clause_buffer = ''
        abc +=1
        clause_buffer += c
        index+=1
        while index < chars.length && abc > 0
          clause_buffer += chars[index]
          abc +=1 if chars[index] == "("
          abc -=1 if chars[index] == ")"
          index +=1
        end
        
        buffer.push calculate(clause_buffer[1..-2])
      when '+', "*"
        buffer.push c
      else
        read_buffer += c
      end

      index +=1
    end

    if (read_buffer || '') != ''
      buffer.push read_buffer.to_i
    end

    buffer
  end
end

c = CalculatorB.new
p data.map {|f|
  c.calculate f
 }.sum