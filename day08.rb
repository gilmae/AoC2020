require './helper.rb'
require 'optparse'

options = {}
OptionParser.new do |opt|
  opt.on('--input INPUT') { |o| options[:input] = o }
  opt.on('--analyse TRUE|FALSE') {|o| options[:analyse] = o == 'TRUE'}
end.parse!

include Helper
input = options[:input] || "#{__FILE__}".gsub(/\.rb/, ".input")

data = get_data(input)

class Instruction
    attr_accessor :command, :value, :has_executed

    def initialize command, value
        @command = command
        @value = value
        @has_executed = false
    end
end

class Computer
    attr_accessor :accumulator, :instruction, :last_instruction, :executed

    def initialize
        @accumulator = 0
        @instruction = 0
        @last_instruction = 0
    end

    def process instructions
        @executed = {}
        while @instruction < instructions.length
            i = instructions[@instruction]
            break if @executed[@instruction]
            @last_instruction = @instruction

            if i.command ==  "nop"
                @instruction+=1
            elsif i.command == "acc"
                @accumulator += i.value
                @instruction+=1
            elsif i.command == "jmp"
                @instruction += i.value
            end
            @executed[@last_instruction] = true
        end
    end

    def analyse instructions
        @executed = {}

        while @instruction < instructions.length
            i = instructions[@instruction]
            if @executed[@instruction]
                puts "INFINITE LOOP DETECTED"
                break
            elsif @instruction >= instructions.length-1
                puts "NO MORE INSTRUCTIONS"
                break
            end
            
            if i.command ==  "nop"
                @last_instruction = @instruction
                @instruction+=1
            elsif i.command == "acc"
                @accumulator += i.value
                @last_instruction = @instruction
                @instruction+=1
            elsif i.command == "jmp"
                @last_instruction = @instruction
                @instruction += i.value
            end
            puts "#{i.command}\t#{i.value}\t#{@accumulator}\t#{@instruction}\t#{@last_instruction}"
            @executed[@last_instruction] = true
        end
    end
end

instructions = data.map{|l|
    parts = l.split(" ")
    Instruction.new(parts[0], parts[1].to_i)
}

c = Computer.new
c.process instructions
puts c.accumulator

if options[:analyse]
    c = Computer.new
    c.analyse instructions
end
