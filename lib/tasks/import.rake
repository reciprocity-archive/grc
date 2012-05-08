namespace :import do
  desc "Import various documents into CMS"

  task :consolidated, [:filename] => [:environment] do |t, args|
    puts "Import consolidated format from #{args[:filename]}"

    require 'importer/consolidated'
    ActiveRecord::Base.transaction do
      importer = Importer::Consolidated.new
      importer.run_file(args[:filename])
    end
  end

  task :regulation, [:filename] => [:environment] do |t, args|
    puts "Import regulation format from #{args[:filename]}"

    require 'importer/regulation'
    ActiveRecord::Base.transaction do
      importer = Importer::Regulation.new
      importer.run_file(args[:filename])
    end
  end
end
