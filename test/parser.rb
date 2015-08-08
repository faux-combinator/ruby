require 'test/unit'
require_relative '../lib/faux_combinator/parser'

class ParserTest < Test::Unit::TestCase
  def test_paren_parser
    paren_parser = subclass do
      def parse
        expect 'lparen'
        expect 'rparen'
        true
      end
    end

    # LEX: ()
    ast = [lparen_token, rparen_token]
    assert_equal parse(paren_parser, ast), true,
      "can parse basic stuff"
  end

  def test_fail
    fail_parser = subclass do
      def parse
        expect 'anything, really'
      end
    end

    assert_raise(FauxCombinator::ParserException) do
      # LEX:
      ast = []
      parse(fail_parser, ast)
    end
  end

  def test_try
    try_parser = subclass do
      def parse
        expect 'lparen'
        val = try 'id'
        expect 'rparen'
        val ? val[:value] : true
      end

      def parse_id
        expect 'id'
      end
    end

    # LEX: ()
    ast = [lparen_token, rparen_token]
    assert_equal parse(try_parser, ast), true,
      "can still parse basic stuff"

    # LEX: (5)
    ast = [lparen_token, id_token, rparen_token]
    assert_equal parse(try_parser, ast), :a,
      "can parse a try token"
  end

  def test_one_of
    one_of_parser = subclass do
      def parse
        one_of('id', 'num', 'str')[:value]
      end

      def parse_id
        expect 'id'
      end

      def parse_num
        expect 'num'
      end

      def parse_str
        expect 'str'
      end
    end

    # LEX: a
    ast = [id_token]
    assert_equal parse(one_of_parser, ast), :a,
      "can parse one_of's first case"

    # LEX: 5
    ast = [num_token]
    assert_equal parse(one_of_parser, ast), 5,
      "can parse one_of's second case"

    # LEX: "a string here"
    ast = [str_token]
    assert_equal parse(one_of_parser, ast), "a string here",
      "can parse one_of's third case"

    assert_raise(FauxCombinator::ParserException) do
      # LEX: ()
      ast = [lparen_token, rparen_token]
      parse(one_of_parser, ast)
    end
  end

  def test_any_of
    any_of_parser = subclass do
      def parse
        any_of 'num'
      end

      def parse_num
        expect('num')[:value]
      end
    end

    # LEX:
    ast = []
    assert_equal parse(any_of_parser, ast), [],
      "can parse empty number of occurences"

    # LEX: 5
    ast = [num_token]
    assert_equal parse(any_of_parser, ast), [5],
      "can parse ONE occurence"

    # LEX: 5 5 5
    ast = [num_token, num_token, num_token]
    assert_equal parse(any_of_parser, ast), [5, 5, 5],
      "can parse ANY number of occurences"
  end

  def test_many_of
    many_of_parser = subclass do
      def parse
        many_of 'num'
      end

      def parse_num
        expect('num')[:value]
      end
    end

    assert_raise(FauxCombinator::ParserException) do
      # LEX: 
      ast = []
      parse(many_of_parser, ast)
    end

    # LEX: 5
    ast = [num_token]
    assert_equal parse(many_of_parser, ast), [5],
      "can parse ONE occurence"

    # LEX: 5 5 5
    ast = [num_token, num_token, num_token]
    assert_equal parse(many_of_parser, ast), [5, 5, 5],
      "can parse ANY number of occurences"
  end

private
  def subclass(&block)
    Class.new(FauxCombinator::Parser, &block)
  end

  def parse(parser, ast)
    parser.new(ast).parse
  end
    
  def lparen_token
    {type: 'lparen', value: '('}
  end

  def rparen_token
    {type: 'rparen', value: ')'}
  end

  def id_token
    {type: 'id', value: :a}
  end

  def num_token
    {type: 'num', value: 5}
  end

  def str_token
    {type: 'str', value: "a string here"}
  end
end
