Gem::Specification.new do |gem|
  gem.name = "zenoss_client"
  gem.version = File.open('VERSION').readline.chomp
  gem.date		= Date.today.to_s
  gem.platform = Gem::Platform::RUBY
  gem.rubyforge_project  = nil

  gem.author = "Dan Wanek"
  gem.email = "dan.wanek@gmail.com"
  gem.homepage = "http://github.com/zenchild/zenoss_client"

  gem.summary = "A Ruby API for accessing Zenoss via REST"
  gem.description	= <<-EOF
  	This is a Ruby library for accessing Zenoss through its REST interface.  It is a work in progress and as functionality is testing
	it will be added.  For documentation on what the method calls do see the official Zenoss API docs.
  EOF

  gem.files = `git ls-files`.split(/\n/)
  gem.require_path = "lib"
  gem.rdoc_options	= %w(-x wsdl/ -x test/ -x examples/)
  gem.extra_rdoc_files = %w(README.rdoc COPYING.txt)

  gem.required_ruby_version	= '>= 1.8.7'
  gem.add_runtime_dependency  'tzinfo'
  gem.post_install_message	= "See README.rdoc"
end