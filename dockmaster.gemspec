Gem::Specification.new do |s|
  s.name        = 'dockmaster'
  s.version     = '0.1.0'
  s.license     = 'MIT'
  s.authors     = ['Christopher Lutz']
  s.email       = ['lutzblox@gmail.com']

  s.summary     = 'A Ruby documentation-to-webpage tool'
  s.description = 'Dockmaster is a documentation-to-webpage tool for Ruby.'
  s.homepage    = 'https://github.com/chrisblutz/dockmaster'

  s.add_runtime_dependency 'safe_yaml', '~> 1.0'
  s.add_runtime_dependency 'parser', '~> 2.3'
  s.add_runtime_dependency 'unparser', '~> 0.2'
end
