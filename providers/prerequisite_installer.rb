def installing_prerequisite(&block)
  yield
rescue LoadError => e
  
  package_name = e.message.split('--').last.strip
  install_command = 'yum install ' + package_name
  instance = ARGV[0]


  if instance.include? ("author")
  
    dir = '/opt/aem/author/crx-quickstart/install'
      
  elsif instance.include? ("publish")
  
    dir = '/opt/aem/publish/crx-quickstart/install'
  
  else
      exit
  end 
  
  Dir.mkdir(dir) unless File.exists?(dir)

  # install prerequisite
  #puts 'Prerequisite: ' + package_name
  #system(install_command)
  
  # retry
  #puts 'Trying again ...'
  #require package_name
  #retry
end

#installing_prerequisite do
#  require 'htop'
#end

