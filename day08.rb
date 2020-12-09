require './helper.rb'
require 'optparse'

options = {}
OptionParser.new do |opt|
  opt.on('--input INPUT') { |o| options[:input] = o }
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

    end

    def process instructions, allow_corruption_fixes = false
        @executed = {}
        @accumulator = 0
        @instruction = 0
        @last_instruction = 0

        while @instruction < instructions.length
            i = instructions[@instruction]
            break if @executed[@instruction]
            @last_instruction = @instruction

            if i.command ==  "nop"
                if allow_corruption_fixes && has_next_instruction_been_seen?(@instruction+1)
                    @instruction += i.value
                else
                    @instruction+=1
                end
            elsif i.command == "acc"
                @accumulator += i.value
                @instruction+=1
            elsif i.command == "jmp"
                if allow_corruption_fixes && has_next_instruction_been_seen?(@instruction + i.value)
                    @instruction+=1
                else
                    @instruction += i.value
                end
                
            end
            @executed[@last_instruction] = true
        end
    end

    def has_next_instruction_been_seen? i
        @executed[i]
    end
end

instructions = data.map{|l|
    parts = l.split(" ")
    Instruction.new(parts[0], parts[1].to_i)
}

#Part 1
c = Computer.new
c.process instructions
puts c.accumulator

# Part 2
c = Computer.new
c.process instructions, true
puts c.accumulator