require_relative('token')

class Interpreter
  class ValidationError < StandardError; end

  EOF = 'EOF'
  INTEGER = 'INTEGER'
  MINUS = 'MINUS'
  PLUS = 'PLUS'

  attr_reader(
    :eof_is_reached,
    :operands,
    :operators,
    :position_increment_override,
    :position,
    :text
  )

  def initialize(text)
    @operands = []
    @operators = []
    @position = -1
    @position_increment_override = 0
    @text = text
  end

  def run
    increment_position
    first_integer_expected

    increment_position
    operator_expected

    increment_position
    second_integer_expected

    increment_position
    eof_expected

    result
  rescue ValidationError => e
    p e
    exit
  end

  private

  def current_character
    text[position]
  end

  def eof_expected
    if eof_is_reached.nil? || eof_is_reached.type != EOF
      error('Expression not properly terminated with a second integer')
    end
  end

  def error(msg)
    raise ValidationError.new(msg)
  end

  def first_integer_expected
    integer_expected
    error('Expression must start with an integer') if operands.size < 1
  end

  def increment_position
    @position += 1 + position_increment_override
    reset_position_increment_override if position_increment_override > 0
    skip_whitespaces
    @eof_is_reached = Token.new(EOF, nil) if text[position].nil?
  end

  def integer_expected
    chars = []
    idx = 0 # for concatenation of sequential digits
    loop do
      character = text[position + idx]
      chars << Integer(character) # raises ArgumentError if casting to Integer fails
      idx += 1
    end
  rescue ArgumentError, TypeError
    return if chars.size < 1
    @operands << Token.new(INTEGER, chars.join.to_i)
    @position_increment_override = idx - 1
    true
  end

  def operator_expected
    case current_character
    when '+'
      @operators << Token.new(PLUS, current_character)
    when '-'
      @operators << Token.new(MINUS, current_character)
    end
    error('An operator must follow the first integer') if @operators.size < 1
  end

  def second_integer_expected
    integer_expected
    error('An integer must follow the operator') if operands.size != 2
  end

  def skip_whitespaces
    idx = 0 # for detection of sequential spaces
    loop do
      character = text[position + idx]
      break if character != ' '
      idx += 1
    end
    @position += idx
  end

  def reset_position_increment_override
    @position_increment_override = 0
  end

  def result
    case operators[0].type
    when PLUS
      operands[0].value + operands[1].value
    when MINUS
      operands[0].value - operands[1].value
    end
  end
end

exit unless __FILE__ == $PROGRAM_NAME

require_relative('command_line_input')

def run!
  while true
    text = command_line_input('calc> ')
    next if text.empty?
    p Interpreter.new(text).run
  end
rescue Interrupt
  nil
end

run!
