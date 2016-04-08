module Cms
  class SitemapElement < ActiveRecord::Base
    self.table_name = :sitemap_elements
    extend Enumerize

    attr_accessible *attribute_names

    belongs_to :page, polymorphic: true

    attr_accessible :page

    enumerize :changefreq, in: [:default, :always, :hourly, :daily, :weekly, :monthly, :yearly, :never], default: :default

    before_save :set_defaults



    def set_defaults
      default_priority = 0.5
      self.priority = default_priority if priority.blank?
      #self.display_on_sitemap ||= true
    end

    def self.entries(locales = nil)
      locales ||= Cms.config.provided_locales

      local_entries = []
      Cms::SitemapElement.where(display_on_sitemap: "t").map do |e|
        locales.each do |locale|
          entry = { loc: e.url(locale), changefreq: e.change_freq, priority: e.priority}
          local_lastmod = e.lastmod(locale)
          entry[:lastmod] = local_lastmod.to_datetime.strftime if local_lastmod.present?
          local_entries << entry
        end
      end.select do|e|
        if page.respond_to?(:published?)
          next page.published?
        else
          next true
        end
      end

      local_entries
    end

    def url(locale = I18n.locale)
      host = Rails.application.config.action_mailer.default_url_options.try{|opts| "http://#{opts[:host]}" }
      page.try{|p| "#{host}#{p.url(locale)}" }
    end



    def lastmod locale = I18n.locale
      page.try{|p| p.updated_at }
    end

    def change_freq
      if changefreq == :default
        return :monthly
      end

      return changefreq
    end
  end
end