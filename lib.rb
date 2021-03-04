module Paxoeng

  class Command
    def initialize(client, req_id, op)
      @client = client
      @req_id = req_id
      @op = op
    end

    def ==(other)
      @client == get(other, 'client') && @req_id == get(other, 'req_id') && @op == get(other, 'op')
    end

    def to_s
      "Command(#{@client}, #{@req_id}, #{@op})"
    end

    private

    def get(other, var)
      other.instance_variable_get("@#{var}".to_sym)
    end
  end

  class PValue

    def initialize(ballot_name, slot_number, command)
      @ballot_number = ballot_name
      @slot_number = slot_number
      @command = command
    end

    def to_s
      "PV(#{@ballot_number}, #{@slot_number}, #{@command})"
    end
  end

  class ProcessId
    include Comparable

    def initialize(name)
      @name = name
    end

    def <=>(other)
      @name <=> other.instance_variable_get(:@name)
    end

    def to_s
      "#{@name}"
    end
  end

  class BallotNumber
    include Comparable

    def initialize(round, leader_id)
      @round = round
      @leader_id = leader_id
    end

    def <=>(other)
      other_round = other.instance_variable_get(:@round)

      if other_round != @round
        @round - other_round
      else
        @leader_id <=> other.instance_variable_get(:@leader_id)
      end
    end

    def to_s
      "BN(#{@round}, #{@leader_id})"
    end
  end

  class Message

    def initialize(process_id)
      @src = src
    end
  end

  class Process < Thread
    def initialize(env, me)
      @env = env
      @inbox = Queue.new
      @me = me
      super
    end

    def body
      raise 'body must be implemented by a process subclass'
    end

    def run
      body
      env.remove_proc me
    end

    def next_message
      inbox.pop
    end

    def send_message(destination, message)
      env.send_message destination, message
    end

    def deliver(message)
      inbox.push message
    end
  end
end
