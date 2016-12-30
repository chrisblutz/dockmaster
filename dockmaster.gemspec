$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))

require 'dockmaster/version'

Gem::Specification.new do |s|
  s.name        = 'dockmaster'
  s.version     = Dockmaster::VERSION
  s.license     = 'MIT'
  s.authors     = ['Christopher Lutz']
  s.email       = ['lutzblox@gmail.com']

  s.required_ruby_version = '>= 2.1'

  s.files = `git ls-files bin lib LICENSE.txt README.md`.split($RS)
  s.executables << 'dockmaster'

  s.summary     = 'A Ruby documentation-to-webpage tool'
  s.description = 'Dockmaster is a documentation-to-webpage tool for Ruby.'
  s.homepage    = 'https://github.com/chrisblutz/dockmaster'

  s.add_runtime_dependency 'cogwheels', '~> 0.2'
  s.add_runtime_dependency 'parser', '~> 2.3'
  s.add_runtime_dependency('rainbow', '~> 2.2.0')
  s.add_runtime_dependency 'unparser', '~> 0.2.5'

  s.add_development_dependency 'rake', '~> 10.4.2'
end
