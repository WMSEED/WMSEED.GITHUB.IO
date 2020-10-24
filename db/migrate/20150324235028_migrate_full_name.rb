class MigrateFullName < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL
      UPDATE users set name = full_name where full_name is not null;
    SQL

    execute <<-SQL
          DROP VIEW IF EXISTS contribution_reports_for_project_owners;
          CREATE OR REPLACE VIEW contribution_reports_for_project_owners AS
          SELECT
            b.project_id,
            coalesce(r.id, 0) as reward_id,
            p.user_id as project_owner_id,
            r.description as reward_description,
            r.deliver_at::date as deliver_at,
            b.confirmed_at::date,
            b.value as contribution_value,
            (b.value* (SELECT value::numeric FROM settings WHERE name = 'catarse_fee') ) as service_fee,
            u.email as user_email,
            u.cpf as cpf,
            u.name as user_name,
            b.payer_email as payer_email,
            b.payment_method,
            b.anonymous,
            b.state as state,
            coalesce(u.address_street, b.address_street) as street,
            coalesce(u.address_complement, b.address_complement) as complement,
            coalesce(u.address_number, b.address_number) as address_number,
            coalesce(u.address_neighbourhood, b.address_neighbourhood) as neighbourhood,
            coalesce(u.address_city, b.address_city) as city,
            coalesce(u.address_state, b.address_state) as address_state,
            coalesce(u.address_zip_code, b.address_zip_code) as zip_code
          FROM
            contributions b
          JOIN users u ON u.id = b.user_id
          JOIN projects p ON b.project_id = p.id
          LEFT JOIN rewards r ON r.id = b.reward_id
          WHERE
            b.state IN ('confirmed', 'waiting_confirmation');
    SQL
    remove_column :users, :full_name
  end
end
