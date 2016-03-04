module FauxCombinator
  class Lexer
    # Initializes the parser with the given array of rules
    # 
    # @param [Array<Array<String>>] rules, formatted so:
    #   [ [ /regexp/, 'name' ], ... ]
    def initialize(rules)
      @rules = rules
    end

    def parse(code)
      tokens = []
      while code != ''
        code[/^ */] = '' # skip whitespace
        if (rule = @rules.find{ |rule| code =~ /^(#{rule[0]})/ })
          tokens << {type: rule[1], value: $1}
          code = code[$1.length..-1]
        else
          error "Unable to parse #{code[0..15]} with the given rules"
        end
      end
      tokens
    end

    private
      def error(message)
        raise LexerException.new(message)
      end
  end

  class LexerException < Exception
  end
end
