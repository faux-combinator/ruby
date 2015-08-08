module FauxCombinator
  class Parser
    # Initializes a parser with the given array of tokens
    #
    # @param [Array<Array<String>>] tokens
    #   An array of tokens constructed by the Lexer
    def initialize(tokens)
      tokens << {type: 'eof'}
      @tokens = tokens
    end

    def run(matcher)
      send(:"parse_#{matcher}")
    end

    def expect(type)
      token = @tokens.shift
      if token[:type] != type
        error "Expected token #{type}, found #{token[:type]} instead"
      end
      token
    end

    def try(matcher)
      tokens = @tokens.dup # shallow clone is enough
      run(matcher)
    rescue ParserException => e
      @tokens = tokens
      false
    end

    def one_of(*matchers)
      matchers.each do |matcher|
        if (value = try(matcher))
          return value # `def` return
        end
      end

      error "unable to parse oneOf cases: #{matchers.join ','}"
    end

    def any_of(matcher)
      values = []
      while (value = try(matcher))
        values << value
      end
      values
    end

    def many_of(matcher)
      # force first occurence
      [run(matcher)] + any_of(matcher)
    end

  private
    def error(message)
      raise ParserException.new(message)
    end
  end

  class ParserException < Exception
  end
end
