# frozen_string_literal: true

require 'rake/testtask'

task default: :test

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task :lint do
  sh 'rubocop'
end

task :clean do
  sh 'rm -f omu-sms-*.gem'
end

namespace :gem do
  task :build do
    sh 'gem build'
  end
end

task package: %w[clean gem:build]
