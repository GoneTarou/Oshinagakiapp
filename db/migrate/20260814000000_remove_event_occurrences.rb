class RemoveEventOccurrences < ActiveRecord::Migration[8.1]
  def up
    occurrences = select_all(<<~SQL)
      SELECT event_occurrences.id, event_occurrences.event_id, event_occurrences.number, events.name AS event_name
      FROM event_occurrences
      INNER JOIN events ON events.id = event_occurrences.event_id
    SQL

    occurrences.each do |occurrence|
      name = event_name_for(occurrence.fetch("event_name"), occurrence.fetch("number"))
      event_id = event_id_for(name)

      execute <<~SQL
        UPDATE lists
        SET event_id = #{event_id}
        WHERE event_occurrence_id = #{occurrence.fetch("id")}
      SQL
    end

    remove_reference :lists, :event_occurrence, foreign_key: true
    drop_table :event_occurrences

    legacy_event_ids = occurrences.map { |occurrence| occurrence.fetch("event_id") }.uniq
    legacy_event_ids.each do |event_id|
      execute <<~SQL
        DELETE FROM events
        WHERE id = #{event_id}
          AND NOT EXISTS (SELECT 1 FROM lists WHERE lists.event_id = events.id)
      SQL
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "開催回を含むイベント名から開催回を復元できません"
  end

  private

  def event_name_for(event_name, number)
    raise ActiveRecord::IrreversibleMigration, "開催回が未設定のイベントは移行できません" if number.blank?

    name = if event_name == "コミックマーケット"
      "#{event_name}C#{number}"
    else
      "#{event_name}#{number}"
    end

    if name.length > 20
      raise ActiveRecord::IrreversibleMigration, "移行後のイベント名が20文字を超えます: #{name}"
    end

    name
  end

  def event_id_for(name)
    existing_event_id = select_value(
      "SELECT id FROM events WHERE name = #{connection.quote(name)} LIMIT 1"
    )
    return existing_event_id if existing_event_id.present?

    timestamp = connection.quote(Time.current)
    execute <<~SQL
      INSERT INTO events (name, created_at, updated_at)
      VALUES (#{connection.quote(name)}, #{timestamp}, #{timestamp})
    SQL

    select_value("SELECT id FROM events WHERE name = #{connection.quote(name)} LIMIT 1")
  end
end
