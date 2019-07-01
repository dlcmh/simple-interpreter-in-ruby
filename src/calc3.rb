require_relative('token')

class Interpreter
  class EofReached < StandardError; end
  class ValidationError < StandardError; end

  INTEGER = 'INTEGER'
  MINUS = 'MINUS'
  PLUS = 'PLUS'

  attr_reader(
    :eof_is_reached,
    :operands,
    :operator,
    :position_increment_override,
    :position,
    :result,
    :text
  )

  def initialize(text)
    @text = text
    @position = -1
    @position_increment_override = 0
    @result = 0
    reset_operands_and_operator
  end

  def run
    first_integer_expected
    loop do
      operation_expected
    end
    raise EofReached
  rescue ValidationError => e
    p e
    exit
  rescue EofReached
    result
  end

  private

  def current_character
    text[position]
  end

  def determine_if_eof_reached
    raise EofReached if text[position].nil?
  end

  def error(msg)
    raise ValidationError.new(msg)
  end

  def first_integer_expected
    increment_position
    integer_expected
    error('Expression must start with an integer') if operands.size < 1
    update_result
  end

  def increment_position
    @position += 1 + position_increment_override
    reset_position_increment_override if position_increment_override > 0
    skip_whitespaces
    determine_if_eof_reached
  end

  def integer_expected
    chars = []
    idx = 0 # for concatenation of sequential digits
    loop do
      character = text[position + idx]
      chars << Integer(character) # raises ArgumentError if casting to Integer fails
                                  # raises TypeError if character is nil
      idx += 1
    end
  rescue ArgumentError, TypeError
    return if chars.size < 1
    @operands << Token.new(INTEGER, chars.join.to_i)
    @position_increment_override = idx - 1
    true
  end

  def operation_expected
    increment_position
    operator_expected

    increment_position
    integer_after_operator_expected

    update_result
  end

  def operator_expected
    case current_character
    when '+'
      @operator = Token.new(PLUS, current_character)
    when '-'
      @operator = Token.new(MINUS, current_character)
    end
    error('An operator must precede an operand') if operator.nil?
  end

  def integer_after_operator_expected
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

  def reset_operands_and_operator(initial_operand = nil)
    initial_operand.nil? ? @operands = [] : @operands = [initial_operand]
    @operator = nil
  end

  def reset_position_increment_override
    @position_increment_override = 0
  end

  def update_result
    @result = case operator&.type
              when PLUS
                operands[0].value + operands[1].value
              when MINUS
                operands[0].value - operands[1].value
              else
                operands[0].value
              end
    reset_operands_and_operator(Token.new(INTEGER, result))
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
