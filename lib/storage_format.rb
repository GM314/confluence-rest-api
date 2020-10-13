class PagePayload
  attr_accessor :page_format

  VALID_OPTIONS = [:type, :title, :spacekey, :content, :pageid, :parentid, :version]

  def initialize(**options)
    options.each do |key, value|
      # puts "--> #{key} = #{value}"
      raise "\n*** Error: unknown option #{key.inspect}\nValid option are:\n#{VALID_OPTIONS}" unless (VALID_OPTIONS.include?(key))

      instance_variable_set("@#{key}", value)
    end
    @page_format = get_type_of_storage(@type)
  end

  def get_type_of_storage(type)
    case type
    when 'create_page_with_no_parent'
      if [@title, @spacekey, @content].include?(nil)
        puts "*** ERROR: Undefined parameter(s)\n    Inspection: #{self.inspect}"
        exit(false)
      else
        %Q(
        {
          "type": "page",
          "title": "#{@title}",
          "space": {
            "key": "#{@spacekey}"
          },
          "body": {
            "storage": {
              "value": "#{@content}",
                "representation": "storage"
            }
          }
        }
        )
      end
    when 'create_page_with_parent'
      if [@parentid, @title, @spacekey, @content].include?(nil)
        puts "*** ERROR: Undefined parameter(s)\n    Inspection: #{self.inspect}"
        exit(false)
      else
        %Q(
        {
            "type": "page",
            "ancestors": [{"type":"page","id":"#{@parentid}"}],
            "title": "#{@title}",
            "space": {
                "key": "#{@spacekey}"
            },
            "body": {
                "storage": {
                    "value": "#{@content}",
                    "representation": "storage"
                }
            }
        }
        )
      end
    when 'update_page_with_no_parent'
      if [@pageid, @title, @spacekey, @content, @version].include?(nil)
        puts "*** ERROR: Undefined parameter(s)\n    Inspection: #{self.inspect}"
        exit(false)
      else
        %Q(
        {
            "id":"#{@pageid}",
            "type":"page",
            "title":"#{@title}",
            "space": {
                "key":"#{@spacekey}"
            },
            "body": {
                "storage": {
                    "value":"#{@content}",
                    "representation":"storage"
                }
            },
            "version": {
                "number":"#{@version}"
            }
        }
        )
      end
    when 'update_page_with_parent'
      if [@pageid, @parentid, @title, @spacekey, @content, @version].include?(nil)
        puts "*** ERROR: Undefined parameter(s)\n    Inspection: #{self.inspect}"
        exit(false)
      else
        %Q(
        {
            "id":"#{@pageid}",
            "type":"page",
            "ancestors": [{"type":"page","id":"#{@parentid}"}],
            "title":"#{@title}",
            "space": {
                "key":"#{@spacekey}"
            },
            "body": {
                "storage": {
                    "value":"#{@content}",
                    "representation":"storage"
                }
            },
            "version": {
                "number":"#{@version}"
            }
        }
        )
      end
    else
      puts "***ERROR: Wrong parameters for #{self.class.name}"
      exit(false)
    end
  end
end