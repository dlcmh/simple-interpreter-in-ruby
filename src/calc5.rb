INTEGER, PLUS, MINUS, MUL, DIV, EOF = %w[INTEGER PLUS MINUS MUL DIV EOF]

class Token
  attr_reader :type, :value

  def initialize(type, value)
    @type = type
    @value = value
  end

  def to_s
    "Token(#{type}, #{value.inspect})"
  end

  def inspect
    to_s
  end
end

class Lexer
  attr_reader :text, :pos, :current_char

  def initialize(text)
    @text = text
    @pos = 0
    @current_char = text[pos]
  end

  def error
    raise ('Invalid character')
  end

  def advance
    @pos += 1
    if pos > text.size - 1
      @current_char = nil
    else
      @current_char = text[pos]
    end
  end

  def skip_whitespace
    while !current_char.nil? && current_char.strip.empty?
      advance
    end
  end

  def integer
    result = ''
    while !current_char.nil? && /\d/.match(current_char)
      result << current_char
      advance
    end
    result.to_i
  end

  def get_next_token
    while !current_char.nil?
      if current_char.strip.empty?
        skip_whitespace
        next
      end

      if /\d/.match(current_char)
        return Token.new(INTEGER, integer)
      end

      if current_char == '+'
        advance
        return Token.new(PLUS, '+')
      end

      if current_char == '-'
        advance
        return Token.new(MINUS, '+')
      end

      if current_char == '*'
        advance
        return Token.new(MUL, '*')
      end

      if current_char == '/'
        advance
        return Token.new(DIV, '/')
      end

      error
    end

    Token.new(EOF, nil)
  end
end

class Interpreter
  attr_reader :lexer, :current_token

  def initialize(lexer)
    @lexer = lexer
    @current_token = lexer.get_next_token
  end

  def error
    raise 'Invalid syntax'
  end

  def eat(token_type)
    if current_token.type == token_type
      @current_token = lexer.get_next_token
    else
      error
    end
  end

  def factor
    token = current_token
    eat(INTEGER)
    token.value
  end

  def term
    result = factor
    while [MUL, DIV].include?(current_token.type)
      token = current_token
      eat(token.type)
      if token.type == MUL
        result = result * factor
      elsif token.type == DIV
        result = result / factor
      end
    end
    result
  end

  def expr
    result = term
    while [PLUS, MINUS].include?(current_token.type)
      token = current_token
      eat(token.type)
      if token.type == PLUS
        result = result + term
      elsif token.type == MINUS
        result = result - term
      end
    end
    result
  end
end

lexer = Lexer.new('21 + 10 / 2 - 6 * 2') # => 14
interpreter = Interpreter.new(lexer)
result = interpreter.expr
p result
