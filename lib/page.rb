class PageObject < ConfluenceClient

  attr_reader :title, :id, :version, :status, :created, :last_update

  def initialize(title, spacekey)
    @title    = title
    @spacekey = spacekey
    @title, @id, @version, @status, @created, @last_update, @url = get_page_info
  end

  def url
    @@conf_url + @url
  end

  #####################################################
  # Includes entire HTML render (including HEADER etc.)
  #####################################################
  def styled_view
    begin
      res = RestClient.get "#{@@conf_url}/#{@@urn}/#{@id}", {params: {
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
      res = RestClient.get "#{@@conf_url}/#{@@urn}/#{@id}", {params: {
          :expand => 'body.view', :os_username => @@login, :os_password => @@pwd
      }}
    rescue RestClient::ExceptionWithResponse => e
      puts Nokogiri.XML(e.response)
    end
    JSON.parse(res)['body']['view']['value']
  end

  def storage_format
    begin
      res = RestClient.get "#{@@conf_url}/#{@@urn}/#{@id}", {params: {
          :expand => 'body.storage', :os_username => @@login, :os_password => @@pwd
      }}
    rescue RestClient::ExceptionWithResponse => e
      puts Nokogiri.XML(e.response)
    end
    JSON.parse(res)['body']['storage']['value']
  end

  def upload_image(image, img_basename)

    if File.exist?("#{img_basename}/#{image}")
      payload = {
          multipart: true,
          file: File.new("#{img_basename}/#{image}", 'rb'),
          comment: 'Automated Ruby import',
          minorEdit: true
      }
      url_mod = "#{@@conf_url}/#{@@urn}/#{@id}/child/attachment?os_username=#{@@login}&os_password=#{@@pwd}"
      begin
        RestClient.post(url_mod, payload, {"X-Atlassian-Token" => "nocheck"})
        true
      rescue RestClient::ExceptionWithResponse => e
        puts Nokogiri.XML(e.response)
        nil
      end
    else
      puts "*** WARNING: Image can't be found for #{img_basename}/#{image}"
      nil
    end
  end

  def delete_attachment(attach_id)
    begin
      RestClient.delete "#{@@conf_url}/#{@@urn}/#{attach_id}", {params: {
          :os_username => @@login, :os_password => @@pwd
      }}
    rescue RestClient::ExceptionWithResponse => e
      puts Nokogiri.XML(e.response)
      return nil
    end
    true
  end

  def image_id(page_id, image_name)

    img = image_name.dup
    img = CGI.escape(img)

    begin
      response = RestClient.get "#{@@conf_url}/#{@@urn}/#{page_id}/child/attachment", {params: {
          :filename => img, 'os_username' => @@login, 'os_password' => @@pwd
      }}

      response = JSON.parse(response)
      if response['results'].any?
        return response['results'][0]['id']
      end
    rescue RestClient::ExceptionWithResponse => e
      puts Nokogiri.XML(e.response)
    end
    nil
  end

  ##################################################################
  private
  ##################################################################

  # Here we can return various metadata for a given page.
  def get_page_info
    begin
      res = RestClient.get "#{@@conf_url}/#{@@urn}", {params: {
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
    # pp JSON.parse(res)['results']
    return JSON.parse(res)['results'][0]['title'],
           JSON.parse(res)['results'][0]['id'],
           JSON.parse(res)['results'][0]['version']['number'],
           JSON.parse(res)['results'][0]['status'],
           JSON.parse(res)['results'][0]['history']['createdDate'],
           JSON.parse(res)['results'][0]['version']['when'],
           JSON.parse(res)['results'][0]['_links']['webui']
  end

end