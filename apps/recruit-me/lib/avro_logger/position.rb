require 'avro'

module AvroLogger

  class Position

    SCHEMA = <<-JSON
      [
        {
          "type": "record",
          "name": "position",
          "fields": [
            {"name": "company", "type": "string"},
            {"name": "position", "type": "string"},
            {"name": "location", "type": "string"},
            {"name": "skill", "type": "string"},
            {"name": "created_at", "type": "int"},
            {"name": "updated_at", "type": "int"}
          ]
        }
      ]
    JSON

    class << self

      def log(positions)
        schema = Avro::Schema.parse(SCHEMA)
        writer = Avro::IO::DatumWriter.new(schema)
        encoder ||= Avro::IO::BinaryEncoder.new(writer)
        file = File.open(Rails.root.join('log/avro/positions.avr'), 'wb')
        dw = Avro::DataFile::Writer.new(file, writer, schema)
        positions.each do |position|
          h = position.attributes.clone
          h.delete '_id'
          h['created_at'] = position.created_at.to_i
          h['updated_at'] = position.updated_at.to_i
          skills = h.delete "skills"
          skills.each do |skill|
            o = h.dup
            o['skill'] = skill
            dw << o
          end
        end
        dw.close
      end

    end
  end

end