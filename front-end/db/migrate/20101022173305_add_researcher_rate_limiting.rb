class AddResearcherRateLimiting < ActiveRecord::Migration
  def self.up
    add_column :researchers, :rate_limited, :boolean
  end

  def self.down
    remove_column :researchers, :rate_limited, :boolean
  end
end
