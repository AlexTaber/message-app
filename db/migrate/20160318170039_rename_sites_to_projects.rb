class RenameSitesToProjects < ActiveRecord::Migration
  def change
    rename_table :sites, :projects
    rename_column :conversations, :site_id, :project_id
    rename_column :invites, :site_id, :project_id
    rename_column :requests, :site_id, :project_id
    rename_column :user_sites, :site_id, :project_id
    rename_column :tiers, :admin_sites, :admin_projects
    rename_column :tiers, :users_per_site, :users_per_project
    rename_table :user_sites, :user_projects
  end
end
