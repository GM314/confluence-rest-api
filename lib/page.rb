require 'nokogiri'

class PageObject < ConfluenceClient

  attr_reader :title, :id, :version, :status, :created, :created_by, :last_updated

  def initialize(title_or_id, spacekey)
    if title_or_id.is_a? Integer
      @title, @id, @version, @status, @created, @created_by, @last_updated, @url = get_page_info_by_id(title_or_id.to_s, spacekey)
    else
      @title, @id, @version, @status, @created, @created_by, @last_updated, @url = get_page_info_by_title(title_or_id, spacekey)
    end
  end

  def url
    unless @url.nil?
      @@conf_url + @url
    end
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

  def delete_page(page_id)
    begin
      RestClient.delete "#{@@conf_url}/#{@@urn}/#{page_id}", {params: {
          :os_username => @@login, :os_password => @@pwd
      }}
    rescue RestClient::ExceptionWithResponse => e
      puts Nokogiri.XML(e.response)
      return nil
    end
    true
  end

  def labels(page_id)
    begin
      res = RestClient.get "#{@@conf_url}/#{@@urn}/#{page_id}/label", {params: {
          :os_username => @@login, :os_password => @@pwd,
          :start => 0, :limit => 1000
      }}
    rescue RestClient::ExceptionWithResponse => e
      puts Nokogiri.XML(e.response)
      nil
    end
    size = JSON.parse(res)['size']
    if size > 0
      size -= 1
      labels = Array.new
      (0..size).each do |idx|
        labels << JSON.parse(res)['results'][idx]["name"]
      end
      labels
    else
      nil
    end
  end

  # Return an array of all page attachment information
  def get_all_attachments(page_id)

    url = "#{@@conf_url}/#{@@urn}/#{page_id}/child/attachment?os_username=#{@@login}&os_password=#{@@pwd}&status=current"

    begin
      atts = RestClient.get url, :content_type => 'application/json', :accept => 'json'
    rescue RestClient::ExceptionWithResponse => e
      puts Nokogiri.XML(e.response)
      nil
    end

    unless atts.nil?
      JSON.parse(atts)["results"]
    end
  end

  def attach_binary_file(file_name, file_basename)

    if File.exist?("#{file_basename}/#{file_name}")
      payload = {
          multipart: true,
          file: File.new("#{file_basename}/#{file_name}", 'rb'),
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
      puts "*** WARNING: File can't be found for #{file_basename}/#{file_name}"
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

  def attachment_id(attachment_name)

    fname = attachment_name.dup
    fname = CGI.escape(fname)

    begin
      response = RestClient.get "#{@@conf_url}/#{@@urn}/#{@id}/child/attachment", {params: {
          :filename => fname, 'os_username' => @@login, 'os_password' => @@pwd
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

  def save_file_attachments(page_id, storage_path)
    if File.writable? storage_path
      att_array = get_all_attachments(page_id)

      att_array.each do |line|
        download_hash = line.to_hash
        title = download_hash["title"]
        url   = @@conf_url + download_hash["_links"]["download"] + "&os_username=#{@@login}&os_password=#{@@pwd}"

        File.open(storage_path + title, 'wb') {|f|
          block = proc { |response|
            response.read_body do |chunk|
              f.write chunk.to_s
            end
          }
          RestClient::Request.execute(method: :get,
                                      url: url,
                                      block_response: block)
        }
      end
    else
      puts "*** ERROR: Cannot write to path: #{storage_path}"
      puts "   Skipping."
      return false
    end
    true
  end

  ##################################################################
  private
  ##################################################################

  # Here we can return various metadata for a given page.
  def get_page_info_by_title(title, spacekey)
    begin
      res = RestClient.get "#{@@conf_url}/#{@@urn}", {params: {
          :title => title, :spaceKey => spacekey, :os_username => @@login, :os_password => @@pwd, :expand => 'version,history'
      }}
    rescue RestClient::ExceptionWithResponse => e
      puts Nokogiri.XML(e.response)
    end
    if res.nil? || JSON.parse(res)['results'][0].nil?
      puts '*** WARNING: Page ID not found.'
      puts "             Page: #{title}"
      puts "             Space Key: #{spacekey}"
      return nil
    else
      return JSON.parse(res)['results'][0]['title'],
             JSON.parse(res)['results'][0]['id'],
             JSON.parse(res)['results'][0]['version']['number'],
             JSON.parse(res)['results'][0]['status'],
             JSON.parse(res)['results'][0]['history']['createdDate'],
             JSON.parse(res)['results'][0]['history']['createdBy']['username'],
             JSON.parse(res)['results'][0]['version']['when'],
             JSON.parse(res)['results'][0]['_links']['webui']
    end
  end

  def get_page_info_by_id(id, spacekey)
    begin
      res = RestClient.get "#{@@conf_url}/#{@@urn}/#{id}?os_username=#{@@login}&os_password=#{@@pwd}&expand=version,history"
    rescue RestClient::ExceptionWithResponse => e
      puts Nokogiri.XML(e.response)
    end
    # if res.nil? || JSON.parse(res)['results'].nil?
    if res.nil?
      puts "*** WARNING: Page not found for id: #{id}"
      puts "             Space Key: #{spacekey}"
      return nil
    else
      return JSON.parse(res)['title'],
          JSON.parse(res)['id'],
          JSON.parse(res)['version']['number'],
          JSON.parse(res)['status'],
          JSON.parse(res)['history']['createdDate'],
          JSON.parse(res)['history']['createdBy']['username'],
          JSON.parse(res)['version']['when'],
          JSON.parse(res)['_links']['webui']
    end
  end

end