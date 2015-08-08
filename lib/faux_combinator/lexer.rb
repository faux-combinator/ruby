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
          raise LexerException.new(
            "Unable to parse #{code[0..15]} with the given rules"
          )
        end
      end
      tokens
    end
  end
          #code[0..$1.length - 1] = ''

  class LexerException < Exception
  end
end
