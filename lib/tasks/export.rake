namespace :export do
  desc "Export help data to YAML file"
  task :help, [:filename] => [:environment] do |t, args|
    puts "Exporting help data to #{args[:filename]}"

    File.open(args[:filename], 'w') do |file|
      YAML::dump(Help.all, file)
    end
  end
end