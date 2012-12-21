# encoding: UTF-8
require "stringex/acts_as_url/adapter"

module Stringex
  module ActsAsUrl # :nodoc:
    def self.configure(&block)
      Stringex::Configuration::ActsAsUrl.configure &block
    end

    module ActsAsUrlClassMethods # :doc:
      # Creates a callback to automatically create an url-friendly representation
      # of the <tt>attribute</tt> argument. Example:
      #
      #   acts_as_url :title
      #
      # will use the string contents of the <tt>title</tt> attribute
      # to create the permalink. <strong>Note:</strong> you can also use a non-database-backed
      # method to supply the string contents for the permalink. Just use that method's name
      # as the argument as you would an attribute.
      #
      # The default attribute <tt>acts_as_url</tt> uses to save the permalink is <tt>url</tt>
      # but this can be changed in the options hash. Available options are:
      #
      # <tt>:adapter</tt>:: If specified, will indicate what ORM adapter to use. Default functionality
      #                     is to use the first available adapter. This should work for most cases
      #                     unless you are using multiple ORMs in a single project.
      # <tt>:allow_slash</tt>:: If true, allow the generated url to contain slashes. Default is false[y].
      # <tt>:allow_duplicates</tt>:: If true, allow duplicate urls instead of appending numbers to
      #                              differentiate between urls. Default is false[y].
      # <tt>:duplicate_count_separator</tt>:: String to use when forcing unique urls from non-unique strings.
      #                                       Default is "-".
      # <tt>:exclude_list</tt>:: List of complete strings that should not be transformed by <tt>acts_as_url</tt>.
      #                          Default is empty.
      # <tt>:only_when_blank</tt>:: If true, the url generation will only happen when <tt>:url_attribute</tt> is
      #                             blank. Default is false[y] (meaning url generation will happen always).
      # <tt>:scope</tt>:: The name of model attribute to scope unique urls to. There is no default here.
      # <tt>:sync_url</tt>:: If set to true, the url field will be updated when changes are made to the
      #                      attribute it is based on. Default is false[y].
      # <tt>:url_attribute</tt>:: The name of the attribute to use for storing the generated url string.
      #                           Default is <tt>:url</tt>.
      # <tt>:limit</tt>:: The maximum size a generated url should be. <strong>Note:</strong> this does not
      #                   include the characters needed to enforce uniqueness on duplicate urls.
      #                   Default is nil.
      def acts_as_url(attribute, options = {})
        cattr_accessor :acts_as_url_configuration

        options[:attribute_to_urlify] = attribute
        self.acts_as_url_configuration = Stringex::Configuration::ActsAsUrl.new(options)

        acts_as_url_configuration.adapter.create_callbacks! self
      end


      # Some ORMs function as mixins not base classes and need to have a hook to reinclude
      # and re-extend ActsAsUrl methods
      def included(base)
        super

        base.send :include, Stringex::ActsAsUrl::ActsAsUrlInstanceMethods
        base.send :extend, Stringex::ActsAsUrl::ActsAsUrlClassMethods
      end

      # Initialize the url fields for the records that need it. Designed for people who add
      # <tt>acts_as_url</tt> support once there's already development/production data they'd
      # like to keep around.
      #
      # Note: This method can get very expensive, very fast. If you're planning on using this
      # on a large selection, you will get much better results writing your own version with
      # using pagination.
      def initialize_urls
        acts_as_url_configuration.adapter.initialize_urls! self
      end
    end

    module ActsAsUrlInstanceMethods
      def ensure_unique_url
        acts_as_url_configuration.adapter.ensure_unique_url! self
      end
    end
  end
end
