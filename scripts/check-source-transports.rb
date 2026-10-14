# frozen_string_literal: true

require "ripper"

root = ARGV.fetch(0, File.expand_path("..", __dir__))
files = Dir.glob("{Formula,Casks}/**/*.rb", base: root).sort
abort "No formula or cask files found in #{root}" if files.empty?

violations = []
files.each do |path|
  Ripper.lex(File.read(File.join(root, path))).each do |position, event, value|
    next if event != :on_tstring_content
    next unless value.match?(%r{\b(?:git\+)?ssh://|\b[\w.-]+@[\w.-]+:}i)

    violations << "#{path}:#{position.first}: SSH source transport is forbidden; use HTTPS"
  end
end

abort violations.join("\n") unless violations.empty?

puts "Source transport check passed (#{files.length} formula/cask files)"
