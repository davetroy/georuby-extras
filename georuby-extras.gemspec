Gem::Specification.new do |s|
  s.name     = "georuby-extras"
  s.version  = '0.5.0'
  s.date     = "2008-12-3"
  s.summary  = "Native extensions and extra functions for the GeoRuby library."
  s.email    = "dave@roundhousetech.com"
  s.homepage = "http://github.com/davetroy/georuby-extras"
  s.description = "Provides native implementations of Vincenty ellipsoidal functions; more to come."
  s.has_rdoc = true
  s.authors  = ["David Troy"]
  s.files    = ["ext/extconf.rb", 
		"ext/vincenty.c",
		"lib/georuby-extras.rb"]
  s.test_files = ["test/test_vincenty.rb"]
  s.rdoc_options = ["--main", "README"]
  s.extensions << 'ext/extconf.rb'
  s.extra_rdoc_files = ["Manifest.txt", "README", "History.txt"]
  s.add_dependency("GeoRuby", ["> 1.2.0"])
end
