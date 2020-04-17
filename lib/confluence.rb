require 'rest-client'

class ConfluenceClient

  def initialize(url, name, password)
    @@conf_url   = url
    @@login = name
    @@pwd   = password
  end

  def create_page_with_parent(title, spacekey, content, parentid)

    page_meta = { type: 'create_page_with_parent',
                  title: title,
                  spacekey: spacekey,
                  content: content,
                  parentid: parentid }

    create_page(StorageFormat.new(page_meta).page_format)

  end

  def update_page(payload, pageid)
  #  curl -u admin:admin -X POST -H 'Content-Type: application/json' -d '{"type":"page","title":"new page",
  # "space":{"key":"TST"},"body":{"storage":{"value":"<p>This is <br/> a new page</p>","representation":
  # "storage"}}}' http://localhost:8080/confluence/rest/api/content/ | python -mjson.tool

  url = "#{@@conf_url}/rest/api/content/#{pageid}?os_username=#{@@login}&os_password=#{@@pwd}"
  puts "PAYLOAD: #{payload}"
  puts "URL: #{url}"
  begin
    RestClient.put url, payload, :content_type => 'application/json', :accept => 'json'
  rescue RestClient::ExceptionWithResponse => error
    puts '*** ERROR: RestClient.post failed'
    puts error
  end
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

end