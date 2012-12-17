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

  desc "Delete existing help data and import new help from YAML file"
  task :help, [:filename] => [:environment] do |t, args|
    puts "Importing help data from #{args[:filename]}"

    # for some reason if Help model is not used before YAML.load_file
    # it will raise an exception that Help is undefined, so just make one object.
    Help.new

    helps = YAML.load_file(args[:filename])
    Help.destroy_all
    helps.each do |help|
      # convince Rails that object needs to be saved (by default it thinks it doesn't need saving)
      help.instance_variable_set("@new_record", true)
      help.save!
    end
  end

  desc "Delete existing help data and import default help from seed file"
  task :help_seed, [:filename] => [:environment] do |t, args|
    Rake::Task["import:help"].invoke("#{Rails.root}/db/help_seed.yml")
  end
end
