require './helper.rb'
include Helper
data = get_data("#{__FILE__}".gsub(/\.rb/, ".input"))

class Instruction
    attr_accessor :command, :value, :has_executed

    def initialize command, value
        @command = command
        @value = value
        @has_executed = false
    end
end

class Computer
    attr_accessor :accumulator, :instruction

    def initialize
        @accumulator = 0
        @instruction = 0
    end

    def process instructions
        while @instruction < instructions.length
            i = instructions[@instruction]
            break if i.has_executed
            
            if i.command ==  "nop"
                @instruction+=1
            elsif i.command == "acc"
                @accumulator += i.value
                @instruction+=1
            elsif i.command == "jmp"
                @instruction += i.value
            end
            i.has_executed = true
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

