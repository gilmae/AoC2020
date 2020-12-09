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

def NoOp state, instruction
    return State.new(
        state.accumulator, 
        state.instruction_pointer+1,
        state.executed.merge({state.instruction_pointer=>true}))
end

def Jump state, instruction
    return State.new(
        state.accumulator, 
        state.instruction_pointer+instruction.value,
        state.executed.merge({state.instruction_pointer=>true})
    )
end

def Accumulate state, instruction
    return State.new(
        state.accumulator+instruction.value,
        state.instruction_pointer+1,
        state.executed.merge({state.instruction_pointer=>true})
    )
end

class State
    attr_accessor :accumulator, :instruction_pointer, :executed
    
    def initialize acc, ip, executed
        @accumulator = acc
        @instruction_pointer = ip
        @executed = executed
    end

    def has_instruction_been_processed? instruction=nil
        @executed[instruction || @instruction_pointer]
    end
end

class Computer
    attr_accessor :state

    def initialize
        reset
    end

    def reset
        @executed = {}
        @accumulator = 0
        @instruction = 0
        @last_instruction = 0

    end

    def exec instructions, allow_corruption_fixes = false
        state = State.new(0,0, {})

        while state.instruction_pointer < instructions.length
            i = instructions[state.instruction_pointer]
            break if state.has_instruction_been_processed?
            
            if i.command ==  "nop"
                next_state = NoOp(state,i)
                if allow_corruption_fixes && next_state.has_instruction_been_processed?
                    next_state = Jump(state,i)
                end

                state = next_state
            elsif i.command == "acc"
                state = Accumulate(state,i)
            elsif i.command == "jmp"
                next_state = Jump(state,i)
                if allow_corruption_fixes && next_state.has_instruction_been_processed?
                    next_state = NoOp(state,i)
                end

                state = next_state
            end
        end

        return state
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
state = c.exec instructions
puts state.accumulator


# Part 2
c.reset
state = c.exec instructions, true
puts state.accumulator