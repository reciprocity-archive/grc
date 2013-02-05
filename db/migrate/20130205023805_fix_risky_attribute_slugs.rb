class FixRiskyAttributeSlugs < ActiveRecord::Migration
  def up
    RiskyAttribute.all.each do |ra|
      if ra.slug.match(/^RISKYATTRIBUTE/)
        ra.slug = ra.slug.sub(/^RISKYATTRIBUTE/, 'RA')
        ra.save!
      end
    end
  end

  def down
  end
end
