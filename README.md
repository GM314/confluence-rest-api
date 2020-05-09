# Ruby Confluence REST API Client

[![Gem Version](https://badge.fury.io/rb/confluence-rest-api.svg)](https://badge.fury.io/rb/confluence-rest-api)

### Installation
```cassandraql
gem install confluence-rest-api
```

### Usage
```ruby
require 'confluence-rest-api'

rest_server = 'https://myserver.com'
user_name   = 'username'
password    = 'password'
space_key   = 'space'

##################################################################
# A connection to the client must be done before any page requests
##################################################################
client  = ConfluenceClient.new(rest_server, user_name, password)

#################################
# Query an existing page by title
#################################

page = PageObject.new('page_title', space_key)
if page.id.nil? 
    puts '*** WARNING: Unable to open page: page_title'
else
    puts "Body:         #{page.rendered_body}"
    puts "Fully styled  #{page.styled_view}"
    puts "ID:           #{page.id}"
    puts "Status:       #{page.status}"
    puts "Version:      #{page.version}"
    puts "Created By:   #{page.created_by}"
    puts "Date Created: #{page.created}"
    puts "Date Updated: #{page.last_update}"
    puts "Page URL:     #{page.url}"
end

###############################
# Query an existing page by id
###############################

page = PageObject.new(123456789, space_key)
if page.title.nil? 
    puts '*** WARNING: Unable to open page with id: 123456789'
else
    puts "Body:         #{page.rendered_body}"
    puts "Fully styled  #{page.styled_view}"
    puts "ID:           #{page.id}"
    puts "Status:       #{page.status}"
    puts "Version:      #{page.version}"
    puts "Created By:   #{page.created_by}"
    puts "Date Created: #{page.created}"
    puts "Date Updated: #{page.last_update}"
    puts "Page URL:     #{page.url}"
end

###########################################################
# Create a new page with a page titled "Home" as its parent
###########################################################

home_page = PageObject.new('Home', space_key)
unless home_page.id.nil?
  client.create_page_with_parent('My Page Title', space_key, 'My Page Body Content', home_page.id)
end

#############################
# Add an attachment to a page
#############################

page_obj = PageObject.new('My Page Title', space_key)
unless page_obj.id.nil?
  img_base_name = 'my/image/location'
  image = 'my_image.png'
  if page_obj.attach_binary_file(image, img_base_name).nil?
    puts "*** WARNING: Image attachment #{image} for #{title} was not successful."
  else
    puts "Image attachment #{image} for #{title} was successful."
  end
end

##################################
# Remove an attachment from a page
##################################

page_obj = PageObject.new('My Page Title', space_key)
id = page_obj.attachment_id('my_image.png')
if id.nil?
  puts "Attachment doesn't exist."
elsif page_obj.delete_attachment(id).nil?
    puts "*** WARNING: Attachment with ID #{id} was not deleted."
else
    puts "Attachment with ID #{id} was deleted"
end


##################################################
# Get an array listing of the page attachment data
##################################################
page_obj = PageObject.new('My Page Title', space_key)
att_array = get_all_attachments(page_obj.id)
att_array.each do |line|
  entry_hash = line.to_hash
  title = entry_hash["title"]
  uri   = entry_hash["_links"]["download"]
  puts "Attachment title: #{title}"
  puts "Attachment link : #{uri}"
end

######################################################
# Save all attachments of a page to the given location
######################################################
page_obj = PageObject.new('My Page Title', space_key)
page_obj.save_file_attachments(page_obj.id, './')

###############
# Delete a page
###############

page_obj = PageObject.new('My Page Title', space_key)
if page_obj.delete_page(page_obj.id).nil?
  puts "*** WARNING: Page with ID #{page_obj.id} was not deleted."
else
  puts "Page with ID #{page_obj.id} was deleted."
end


````

### TODO
1. Add tests

