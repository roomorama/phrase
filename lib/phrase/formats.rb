# -*- encoding : utf-8 -*-

module Phrase
  module Formats
    autoload :Custom, 'phrase/formats/custom'
    autoload :Json, 'phrase/formats/json'
    autoload :Csv, 'phrase/formats/csv'
    autoload :Gettext, 'phrase/formats/gettext'
    autoload :GettextTemplate, 'phrase/formats/gettext_template'
    autoload :Ini, 'phrase/formats/ini'
    autoload :Properties, 'phrase/formats/properties'
    autoload :PropertiesXml, 'phrase/formats/properties_xml'
    autoload :Plist, 'phrase/formats/plist'
    autoload :QtPhraseBook, 'phrase/formats/qt_phrase_book'
    autoload :QtTranslationSource, 'phrase/formats/qt_translation_source'
    autoload :Resx, 'phrase/formats/resx'
    autoload :ResxWindowsphone, 'phrase/formats/resx_windowsphone'
    autoload :SimpleJson, 'phrase/formats/simple_json'
    autoload :NodeJson, 'phrase/formats/node_json'
    autoload :Strings, 'phrase/formats/strings'
    autoload :Xml, 'phrase/formats/xml'
    autoload :Tmx, 'phrase/formats/tmx'
    autoload :Xliff, 'phrase/formats/xliff'
    autoload :Yaml, 'phrase/formats/yaml'
    autoload :YamlSymfony, 'phrase/formats/yaml_symfony'
    autoload :PhpArray, 'phrase/formats/php_array'

    class Base
      def self.supports_extension?(extension)
        self.extensions.map(&:to_s).include?(extension.to_s)
      end

      def self.extensions
        []
      end

      def self.directory_for_locale(locale)
        "./"
      end

      def self.filename_for_locale(locale)
        raise "not implemented"
      end

      def self.extract_locale_name_from_file_path(file_path)
        nil
      end

      def self.default_locale_name
        Phrase::Tool::Locale.find_default_locale.try(:name)
      end

      def self.locale_aware?
        false
      end

      def self.target_directory
        "phrase/locales/"
      end

      def self.config
        Phrase::Tool.config
      end
      private_class_method :config
    end

    SUPPORTED_FORMATS = {
      custom: Phrase::Formats::Custom,
      json: Phrase::Formats::Json,
      csv: Phrase::Formats::Csv,
      gettext: Phrase::Formats::Gettext,
      gettext_template: Phrase::Formats::GettextTemplate,
      ini: Phrase::Formats::Ini,
      properties: Phrase::Formats::Properties,
      properties_xml: Phrase::Formats::PropertiesXml,
      plist: Phrase::Formats::Plist,
      qph: Phrase::Formats::QtPhraseBook,
      ts: Phrase::Formats::QtTranslationSource,
      resx: Phrase::Formats::Resx,
      resx_windowsphone: Phrase::Formats::ResxWindowsphone,
      simple_json: Phrase::Formats::SimpleJson,
      node_json: Phrase::Formats::NodeJson,
      strings: Phrase::Formats::Strings,
      xml: Phrase::Formats::Xml,
      tmx: Phrase::Formats::Tmx,
      xlf: Phrase::Formats::Xliff,
      yml: Phrase::Formats::Yaml,
      yml_symfony: Phrase::Formats::YamlSymfony,
      php_array: Phrase::Formats::PhpArray,
    }

    def self.config
      Phrase::Tool.config
    end

    def self.custom_handler
      handler_class_for_format(:custom)
    end

    def self.target_directory(format_name)
      handler = handler_class_for_format(format_name)
      custom_handler.target_directory || handler.target_directory
    end

    def self.directory_for_locale_in_format(locale, format_name)
      handler = handler_class_for_format(format_name)
      custom_directory = custom_handler.directory_for_locale(locale, format_name)
      custom_directory || handler.directory_for_locale(locale)
    end

    def self.filename_for_locale_in_format(locale, format_name)
      handler = handler_class_for_format(format_name)
      custom_filename = custom_handler.filename_for_locale(locale, format_name)
      custom_filename || handler.filename_for_locale(locale)
    end

    def self.file_format_exposes_locale?(file_path)
      format = guess_possible_file_format_from_file_path(file_path)
      format.nil? ? false : handler_class_for_format(format).locale_aware?
    end

    def self.detect_locale_name_from_file_path(file_path)
      format = guess_possible_file_format_from_file_path(file_path)
      format.nil? ? nil : handler_class_for_format(format).extract_locale_name_from_file_path(file_path)
    end

    def self.handler_class_for_format(format_name)
      SUPPORTED_FORMATS.fetch(format_name.to_sym)
    end
    private_class_method :handler_class_for_format

    def self.guess_possible_file_format_from_file_path(file_path)
      extension = extension_from_file_path(file_path)
      possible_format = SUPPORTED_FORMATS.keys.find do |format|
        SUPPORTED_FORMATS[format].send(:supports_extension?, extension)
      end
    end
    private_class_method :guess_possible_file_format_from_file_path

    def self.extension_from_file_path(file_path)
      file_path.split('.').last.downcase
    end
    private_class_method :extension_from_file_path
  end
end
