class CreateDomainEventsLog < ActiveRecord::Migration[8.1]
  def change
    create_table :domain_events_log, id: :string do |t|
      t.string :event_type, null: false
      t.json :payload, null: false, default: {}
      t.string :source_command
      t.datetime :occurred_at, null: false
      t.timestamps
    end
    add_index :domain_events_log, :event_type
    add_index :domain_events_log, :occurred_at
  end
end
