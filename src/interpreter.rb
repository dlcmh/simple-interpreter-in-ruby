require_relative('token')

class Interpreter
  EOF = 'EOF'
  INTEGER = 'INTEGER'
  MINUS = 'MINUS'
  PLUS = 'PLUS'

  attr_reader :current_char, :current_token, :pos, :text

  def initialize(text)
    @pos = 0
    @text = text
    @current_char = text[pos]
  end

  def expr
    @current_token = get_next_token

    left = current_token
    eat(INTEGER)

    op = current_token
    case op.type
    when PLUS
      eat(PLUS)
    when MINUS
      eat(MINUS)
    end

    right = current_token
    eat(INTEGER)

    case op.type
    when PLUS
      left.value + right.value
    when MINUS
      left.value - right.value
    end
  end

  private

  def advance
    @pos += 1
    return @current_char = nil if pos > text.size - 1
    return @current_char = text[pos]
  end

  def current_char_is_digit
    true if Integer(current_char) rescue false
  end

  def current_char_is_minus
    current_char == '-'
  end

  def current_char_is_plus
    current_char == '+'
  end

  def current_char_is_space
    current_char == ' '
  end

  def eat(token_type)
    return error unless current_token.type == token_type
    @current_token = get_next_token
  end

  def error
    raise 'Error parsing input'
  end

  def get_next_token
    while !current_char.nil?
      case
      when current_char_is_digit
        return Token.new(INTEGER, current_char.to_i)
      when current_char_is_minus
        advance
        return Token.new(MINUS, current_char)
      when current_char_is_plus
        advance
        return Token.new(PLUS, current_char)
      else
        error
      end
    end
    Token(EOF, nil)
  end

  def skip_whitespace
    while !current_char.nil? and current_char_is_space
      advance
    end
  end
end

exit unless __FILE__ == $PROGRAM_NAME

require_relative('command_line_input')

def run!
  while true
    text = command_line_input('calc> ')
    next if text.empty?
    interpreter = Interpreter.new(text)
    result = interpreter.expr
    p result
  end
rescue Interrupt
  nil
end

run!
