site :opscode

metadata

# mysql::ruby dependency seems to bypass this.
# manual `apt-get update` may be necessary to
# converge on test-kitchen despite this dependency.
group :integration do
  cookbook 'apt', '~> 2.0'
end
