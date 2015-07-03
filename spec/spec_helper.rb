ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$LOAD_PATH.unshift File.join(ROOT, 'lib')
$LOAD_PATH.unshift File.join(ROOT, 'spec')

require 'lsperfm'

def load_fixture(name)
  IO.read("spec/fixtures/#{name}")
end
