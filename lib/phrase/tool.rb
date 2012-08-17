# -*- encoding : utf-8 -*-

require 'fileutils'
require 'rubygems'
require 'phrase'

class Phrase::Tool
  autoload :Config, 'phrase/tool/config'
  autoload :Options, 'phrase/tool/options'
  autoload :TagValidator, 'phrase/tool/tag_validator'
  
  ALLOWED_FILE_TYPES = %w(yml pot po)
  
  attr_accessor :config, :options
  
  def initialize(argv)
    @args = argv
  end

  def run
    subcommand = @args.first
    
    @config = Phrase::Tool::Config.new
    @options = Phrase::Tool::Options.new(@args, subcommand)

    case subcommand
      when /init/
        init
      when /push/
        push
      when /pull/
        pull
      else
        if @options.get(:version)
          print_version
        else
          print_usage
        end
    end
  end

protected

  def init
    secret = @options.get(:secret)
    unless secret.present?
      print_error "Need a secret to init, but found none."
      print_error "Please provide the --secret=YOUR_SECRET parameter."
      exit(41)
    end
    
    @config.secret = secret
    puts "Wrote secret to config file .phrase"
    
    default_locale_name = @options.get(:default_locale)    
    create_locale(default_locale_name)
    make_locale_default(default_locale_name)
  end

  def push
    check_config_available
    tags = @options.get(:tags)
    unless tags.empty? or valid_tags_are_given?(tags)
      print_error "Invalid tags: Only letters, numbers, underscores and dashes are allowed"
      exit(43)
    end
    
    files = choose_files_to_upload
    if files.empty?
      puts "Could not find any files to upload :("
      exit(43)
    end
    
    upload_files(files, tags)
  end

  def pull
    check_config_available
    
    create_locales_folder!
    
    locale = args[1]
    locales = []
    if locale && locale.strip != ''
      locales = [locale]
    else
      locales = fetch_locales
    end
    
    locales.each do |locale_name|
      print "Downloading phrase.#{locale_name}.yml..."
      fetch_translations_for_locale(locale_name)
    end
  end
  
  def print_usage
    $stderr.puts <<USAGE
usage: phrase <command> [<args>]

  phrase init --secret=<YOUR SECRET> --default-locale=<DEFAULT LOCALE>

  phrase push FILE [--tags=<tags>]
  phrase push DIRECTORY [--tags=<tags>]
  
  phrase pull [LOCALE]
  
  phrase --version
USAGE
  end
  
  def print_version
    puts "phrase version #{Phrase::VERSION}"
  end
  
private
  def choose_files_to_upload
    file_name = args[1]
  
    unless file_name
      if self.class.rails_default_locale_folder_is_available
        file_name = self.class.rails_default_locale_folder
        puts "No file or directory specified, using #{self.class.rails_default_locale_folder}"
      else 
        print_error "Need either a file or directory:"
        print_error "phrase push FILE"
        print_error "phrase push DIRECTORY"
        exit(46)
      end
    end

    unless File.exist?(file_name)
      print_error "The file #{file_name} could not be found."
      exit(42)
    end

    if File.directory?(file_name)
      files = Dir.glob("#{File.expand_path(file_name)}/**")
    else
      files = [file_name]
    end
  end

  def upload_files(files, tags=[])
    files.each do |file|
      upload_file(file, tags)
    end
  end
  
  def upload_file(file, tags=[])
    valid = true
    
    if File.directory?(file)
      valid = false
    end
    
    unless file_valid?(file)
      valid = false
      print_error "Notice: Could not upload #{file} (type not supported)"
    end
    
    if valid
      begin
        tagged = " (tagged: #{tags.join(", ")})" if tags.size > 0
        puts "Uploading #{file}#{tagged}..."
        api_client.upload(file, File.read(file), tags)
        puts "OK"
      rescue Exception => e
        puts "Failed"
        print_server_error(e.message, file)
      end
    end
  end

  def fetch_translations_for_locale(name)
    begin
      content = api_client.download_translations_for_locale(name)
      puts "OK"
      store_translations_file(name, content)
    rescue Exception => e
      puts "Failed"
      print_server_error(e.message)
    end
  end
  
  def store_translations_file(name, content)
    File.open("phrase/locales/phrase.#{name}.yml", "w") do |file|
      file.write(content)
    end
  end
  
  def fetch_locales
    begin
      locales = api_client.fetch_locales
      puts "Fetched all locales"
      return locales
    rescue Exception => e
      puts "Failed"
      print_server_error(e.message)
      exit(47)
    end
  end
  
  def create_locale(name)
    begin
      api_client.create_locale(name)
      puts "Created locale \"#{name}\""
    rescue Exception => e
      puts "Notice: Locale \"#{name}\" could not be created (maybe it already exists)"
    end
  end
  
  def make_locale_default(name)
    begin
      api_client.make_locale_default(name)
      puts "Locale \"#{name}\" is now the default locale"
    rescue Exception => e
      puts "Notice: Locale \"#{name}\" could not be made the default locale"
      print_server_error(e.message)
    end
  end
  
  def api_client
    Phrase::Api::Client.new(@config.secret)
  end

  def print_server_error(message, filename=nil)
    print_error "#{message} (#{filename})"
  end
  
  def print_error(message)
    $stderr.puts message
  end

  def args
    @args
  end
  
  def file_valid?(filepath)
    extension = filepath.split('.').last
    ALLOWED_FILE_TYPES.include?(extension)
  end
  
  def create_locales_folder!
    ::FileUtils.mkdir_p("phrase/locales")
  end
  
  def check_config_available
    if !@config.secret || @config.secret.empty?
      print_error "No config present. You need to initialize phrase first."
      exit(43)
    end
  end
  
  def valid_tags_are_given?(tags)
    tags.each do |tag|
      return false unless TagValidator.valid?(tag)
    end
    true
  end
  
  def self.rails_default_locale_folder
    "./config/locales/"
  end
  
  def self.rails_default_locale_folder_is_available
    File.exist?(rails_default_locale_folder) && File.directory?(rails_default_locale_folder)
  end
end