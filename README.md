# Confluence REST API Client

### Installation
```cassandraql
gem install confluence-rest-api
```

### Usage
```ruby
require_relative 'lib/confluence'
require_relative 'lib/page'
require_relative 'lib/storage_format'

rest_server = 'https://myserver.com'
user_name   = 'username'
password    = 'password'
space_key = 'space'

client  = ConfluenceClient.new(rest_server, username password)

########################
# Query an existing page
########################

page = PageObject.new('page_title', space_key)

puts "Body:         #{page.rendered_body}"
puts "Fully styled  #{page.styled_view}"
puts "ID:           #{page.id}"
puts "Status:       #{page.status}"
puts "Version:      #{page.version}"
puts "Date Created: #{page.created}"
puts "Date Updated: #{page.last_update}"
puts "Page URL:     #{page.url}"

###########################################################
# Create a new page with a page titled "Home" as its parent
###########################################################

home_page = PageObject.new('Home', space_key)
client.create_page_with_parent('My Page Title', space_key, 'My Page Body Content', home_page.id)

````

### TODO
1. Add ability to attach and remove page attachments
1. Commit to GitHub
1. Add tests

