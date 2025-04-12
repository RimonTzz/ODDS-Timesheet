class ChangeClientIdToNullableInSites < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      ALTER TABLE sites ALTER COLUMN client_id DROP NOT NULL;
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE sites ALTER COLUMN client_id SET NOT NULL;
    SQL
  end
end
