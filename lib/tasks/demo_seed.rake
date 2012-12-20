namespace :demo do
  desc "Load demo seed data"
  task :seed => :environment do |t, args|
    demo_seed_file = File.join(Rails.root, 'db', 'demo_seeds', 'demo_seeds.rb')
    load(demo_seed_file)
  end

  task :setup => [:environment, :"db:seed", :"demo:seed"]
  task :reset, [ :subdir ] => [:environment, :"db:reset", :setup]
end
