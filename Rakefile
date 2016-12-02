# frozen_string_literal: true
require 'rake/testtask'

task :default do
  puts `rake -T`
end

Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/*_spec.rb'
  t.warning = false
end

task :run do
  sh 'rerun "rackup -p 9292"'
end

namespace :db do
  task :_setup do
    require 'sequel'
    require_relative 'init'
    Sequel.extension :migration
  end

  desc 'Run database migrations'
  task migrate: [:_setup] do
    puts "Migrating to latest for: #{ENV['RACK_ENV'] || 'development'}"
    Sequel::Migrator.run(DB, 'db/migrations')
    Rake::Task['db:schema'].execute
  end

  desc 'Reset migrations (full rollback and migration)'
  task reset: [:_setup] do
    puts "Rolling back #{ENV['RACK_ENV'] || 'development'} database"
    Sequel::Migrator.run(DB, 'db/migrations', target: 0)
    Rake::Task['db:migrate'].execute
  end

  desc 'Print out final schema to file'
  task schema: [:_setup] do
    DB.extension :schema_dumper
    File.open('db/schema.rb', 'w') do |file|
      header = <<~END
        # This schema file is automatically generated by `rake db:schema`.
        # It will be overwritten periodically so do not make changes.
      END
      puts 'Writing schema to db/schema.rb'
      file.write(header)
      file.write(DB.dump_schema_migration)
    end
  end
end

namespace :vcr do
  desc 'delete cassette fixtures'
  task :wipe do
    sh 'rm spec/fixtures/cassettes/*.yml' do |ok, _|
      puts(ok ? 'Cassettes deleted' : 'No cassettes found')
    end
  end
end

namespace :quality do
  CODE = 'app.rb'

  desc 'run all quality checks'
  task all: [:rubocop, :flog, :flay]

  task :flog do
    sh "flog #{CODE}"
  end

  task :flay do
    sh "flay #{CODE}"
  end

  task :rubocop do
    sh 'rubocop'
  end
end
