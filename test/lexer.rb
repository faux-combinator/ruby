require 'test/unit'
require_relative '../lib/faux_combinator/lexer'

class LexerTest < Test::Unit::TestCase
  def test_basic_parsing
    rules = [
      [ /=/, 'eq' ]
    ]
    assert_equal lex(rules, '='), [eq_token],
      "basic parsing"
    assert_equal lex(rules, '=='), [eq_token, eq_token],
      "multiple occurences"
    assert_equal lex(rules, '= ='), [eq_token, eq_token],
      "skips whitespace"
  end

  def test_multiple_rules
    rules = [
      [ /=/, 'eq' ],
      [ /-/, 'dash' ],
      [ /_/, 'under' ],
    ];

    assert_equal lex(rules, '='), [eq_token],
      "multiple rules can find first"
    assert_equal lex(rules, '-'), [dash_token],
      "multiple rules can find second"
    assert_equal lex(rules, '_'), [under_token],
      "multiple rules can find third"

    assert_equal lex(rules, '=-_'), [eq_token, dash_token, under_token],
      "multiple rules can match all"
    assert_equal lex(rules, '=-  _'), [eq_token, dash_token, under_token],
      "multiple rules can match all with space separation"
  end
    
  def test_capture
    rules = [
      [ '[a-z]+', 'id' ]
    ]

    assert_equal lex(rules, 'abc def'), [
      {type: 'id', value: 'abc'},
      {type: 'id', value: 'def'},
    ], "correctly captures values"
  end

  def test_fail
    assert_raise(FauxCombinator::LexerException) do
      lex([], '=')
    end
  end

private
  def lex(rules, code)
    FauxCombinator::Lexer.new(rules).parse(code)
  end

  def eq_token
    {type: 'eq', value: '='}
  end

  def dash_token
    {type: 'dash', value: '-'}
  end

  def under_token
    {type: 'under', value: '_'}
  end
end

=begin


try { 
  lex(rules, '*');
  fail('Trying to parse a token that has no rule should fail.');
} catch (RuntimeException e) {
  pass('Trying to parse a token that has no rule should fail.');
}

# TODO: implement/add tests for [ 'x', 'y', function(val){} ] form
=end
