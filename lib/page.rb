class PageObject < ConfluenceClient

  attr_reader :id, :version, :status, :created, :last_update

  def initialize(title, spacekey)
    @title    = title
    @spacekey = spacekey
    @id, @version, @status, @created, @last_update, @url = get_page_info
  end

  def url
    @@conf_url + @url
  end

  #####################################################
  # Includes entire HTML render (including HEADER etc.)
  #####################################################
  def styled_view
    begin
      res = RestClient.get "#{@@conf_url}/rest/api/content/#{@id}", {params: {
          :expand => 'body.styled_view', :os_username => @@login, :os_password => @@pwd
      }}
    rescue RestClient::ExceptionWithResponse => e
      puts Nokogiri.XML(e.response)
    end
    JSON.parse(res)['body']['styled_view']['value']
  end

  ##################################################
  # Includes only the rendered HTML BODY of the page
  ##################################################
  def rendered_body
    begin
      res = RestClient.get "#{@@conf_url}/rest/api/content/#{@id}", {params: {
          :expand => 'body.view', :os_username => @@login, :os_password => @@pwd
      }}
    rescue RestClient::ExceptionWithResponse => e
      puts Nokogiri.XML(e.response)
    end
    JSON.parse(res)['body']['view']['value']
  end

  def storage_format
    begin
      res = RestClient.get "#{@@conf_url}/rest/api/content/#{@id}", {params: {
          :expand => 'body.storage', :os_username => @@login, :os_password => @@pwd
      }}
    rescue RestClient::ExceptionWithResponse => e
      puts Nokogiri.XML(e.response)
    end
    JSON.parse(res)['body']['storage']['value']
  end

  ##################################################################
  private
  ##################################################################

  # Here we can return various metadata for a given page.
  def get_page_info
    begin
      res = RestClient.get "#{@@conf_url}/rest/api/content", {params: {
          # :title => @title, :spaceKey => @spacekey, :os_username => @@login, :os_password => @@pwd, :expand => 'version', :expand => 'history'
          :title => @title, :spaceKey => @spacekey, :os_username => @@login, :os_password => @@pwd, :expand => 'version,history'
      }}
    rescue RestClient::ExceptionWithResponse => e
      puts Nokogiri.XML(e.response)
    end
    if JSON.parse(res)['results'][0].nil?
      puts '*** WARNING: Page ID not found.'
      puts "             Page: #{title}"
      puts "             Space Key: #{spacekey}"
    end
    pp JSON.parse(res)['results']
    return JSON.parse(res)['results'][0]['id'],
           JSON.parse(res)['results'][0]['version']['number'],
           JSON.parse(res)['results'][0]['status'],
           JSON.parse(res)['results'][0]['history']['createdDate'],
           JSON.parse(res)['results'][0]['version']['when'],
           JSON.parse(res)['results'][0]['_links']['webui']

  end

end