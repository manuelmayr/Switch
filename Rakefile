# -*- encoding: utf-8 -*-
require "rake/gempackagetask"
require "rake/clean"
# we use "hanna" instead of the default
# rdoc template, since it does'nt scale 
# with the amount of code
#require "rake/rdoctask"

gemspec_file = "switch.gemspec"

spec = eval(File.read(gemspec_file))

task :default => [:package]

# customizing gem package
desc "Creating a gem package"
Rake::GemPackageTask.new(spec) do |pkg| end

desc "Removes trailing whitespace"
task :whitespace do
  sh %{find . -name '*.rb' -exec sed -i '' 's/ *$//g' {} \\;}
end

desc "Remove bothering vim swap files"
task :vim_clean do
  sh %{find . -name '.*.swp' -delete}
end

begin
  require "hanna/rdoctask"
rescue LoadError
  desc "Generate API documentation to docs/rdoc/index.html"
  task(:rdoc) { $stderr.puts "`gem install hanna` to run rdoc with hanna template" }
else
  desc "Generate API documentation to docs/rdoc/index.html"
  Rake::RDocTask.new do |rd|
    rd.rdoc_dir = "docs/rdoc"
    rd.main = "README.txt"
    rd.rdoc_files.include "README.txt", "lib/**/*\.rb"
  
    rd.options << '--all'
    rd.options << '--charset=UTF-8'
  
    rd.options << '--inline-source'
    rd.options << '--line-numbers'
    # For the --file-boxes and --diagram options
    # to work you need graphviz (http://www.graphviz.org/),
    # otherwise delete them
  #  rd.options << '--file-boxes'
  #  rd.options << '--diagram'
  end
end

# clean the  repository
CLEAN.include("pkg", "debug.log", "rspec")

begin
  require "spec/rake/spectask"
rescue LoadError
  desc "Run specs"
  task(:spec) { $stderr.puts "`gem install rspec` to run specs" }
else
  # specs
  namespace :spec do
    for adapter in %w[postgresql]
      # Customizing spec task
      desc "Running specs with #{adapter}"
      Spec::Rake::SpecTask.new(adapter) do |t| 
        t.spec_files = ["./spec/connections/#{adapter}_connection.rb"] +
                       ["./spec/schemas/#{adapter}_schema.rb"] +
                       FileList['./spec/switch/engines/**/*_spec.rb']
      end
    end
  end
  
  # Code Coverage
  desc "Run specs"
  Spec::Rake::SpecTask.new(:spec) do |t|
    t.spec_files = FileList['spec/switch/translation/**/*_spec.rb']
  end
  
  # Code Coverage
  desc "Run specs using RCov"
  Spec::Rake::SpecTask.new(:coverage) do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.rcov = true
  end
end
