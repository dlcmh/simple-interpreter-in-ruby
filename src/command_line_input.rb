require 'readline'

# https://stackoverflow.com/questions/2889720/one-liner-in-ruby-for-displaying-a-prompt-getting-input-and-assigning-to-a-var
def command_line_input(prompt='', newline=false)
  prompt += "\n" if newline
  Readline.readline(prompt, true).squeeze(' ').strip
end
