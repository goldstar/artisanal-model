source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in artisanal-model.gemspec
gemspec

group :benchmarks do
  if RUBY_VERSION < "2.4"
    gem "activesupport", "< 5"
  else
    gem "activesupport"
  end

  gem "benchmark-ips", "~> 2.5"
  gem "dry-initializer"
  gem "hashie"
  gem "virtus"
end
