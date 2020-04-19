require 'rest-client'

class ConfluenceClient

  def initialize(url, name, password)
    @@conf_url = url
    @@login    = name
    @@pwd      = password
  end

  def create_page_with_parent(title, spacekey, content, parentid)

    page_meta = { type:     'create_page_with_parent',
                  title:    title,
                  spacekey: spacekey,
                  content:  content,
                  parentid: parentid }

    create_page(PagePayload.new(page_meta).page_format)

  end

  def update_page_with_parent(page_obj, parent_page_obj, spacekey, content)

    version = page_obj.version + 1

    page_meta = { type:     'update_page_with_parent',
                  pageid:   page_obj.id,
                  parentid: parent_page_obj.id,
                  title:    page_obj.title,
                  spacekey: spacekey,
                  content:  content,
                  version:  version }

    update_page(PagePayload.new(page_meta).page_format, page_obj.id)

  end

  def create_page_with_no_parent(title, spacekey, content)

    page_meta = { type:     'create_page_with_no_parent',
                  title:    title,
                  spacekey: spacekey,
                  content:  content }

    create_page(PagePayload.new(page_meta).page_format)

  end

  def update_page_with_no_parent(page_obj, spacekey, content)

    version = page_obj.version + 1

    page_meta = { type:     'update_page_with_no_parent',
                  pageid:   page_obj.id,
                  title:    page_obj.title,
                  spacekey: spacekey,
                  content:  content,
                  version:  version }

    update_page(PagePayload.new(page_meta).page_format, page_obj.id)

  end

  private

  def create_page(payload)

    url = "#{@@conf_url}/rest/api/content?os_username=#{@@login}&os_password=#{@@pwd}"
    begin
      RestClient.post url, payload, :content_type => 'application/json'
    rescue RestClient::ExceptionWithResponse => error
      puts '*** ERROR: RestClient.post failed'
      pp error
    end
  end

  def update_page(payload, id)

    url = "#{@@conf_url}/rest/api/content/#{id}?os_username=#{@@login}&os_password=#{@@pwd}"
    begin
      RestClient.put url, payload, :content_type => 'application/json', :accept => 'json'
    rescue RestClient::ExceptionWithResponse => error
      puts '*** ERROR: RestClient.put failed'
      puts error
    end
  end

end