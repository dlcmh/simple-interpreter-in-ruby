class Token
  attr_reader :type, :value

  def initialize(type, value)
    @type = type
    @value = value
  end

  def inspect
    to_s
  end

  def to_s
    "Token(#{type}, #{value.inspect})"
  end
end
