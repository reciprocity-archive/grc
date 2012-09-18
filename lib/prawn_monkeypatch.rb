# Monkey patch Prawn to fix 'incompatible character encodings' error in JRuby:
# https://github.com/prawnpdf/prawn/issues/283

require 'prawn'
module Prawn
  module Core
    def self.utf8_to_utf16(str)
      str
    end
  end
end
