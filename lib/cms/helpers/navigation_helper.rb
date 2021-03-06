module Cms
  module Helpers
    module Cms::Helpers::NavigationHelper
      def self.included(base)
        methods = self.instance_methods
        methods.delete(:included)
        if base.respond_to?(:helper_method)
          base.helper_method methods
        end
      end

      def menu(menu_keys = nil, i18n_root = "menu")
        menu_keys ||= %w(about_us services process benefits teams industries blog contacts)

        compute_navigation_keys(menu_keys, i18n_root)
      end

      def sitemap_entries(keys = nil, i18n_root = "sitemap")
        keys ||= [{key: "home", url: root_path}, "about_us", "services", "process", {key: "teams", children_class: Team}, {key: "industries", children_class: Industry}, "blog", "contacts", "career", "privacy_policy", "terms_of_use" ]

        compute_navigation_keys(keys, i18n_root, false)
      end

      def read_also_entries
        compute_navigation_keys(@read_also_entries, "read_also")
      end

      def compute_navigation_keys(keys, i18n_root = "navigation", check_for_active = true)

        h = {}
        keys.keep_if{|e|  ( (e.is_a?(String) || e.is_a?(Symbol)) && e.present? ) ||  (e.is_a?(Hash) || e[:key].present?)   }.each do |key|
          entry = {}
          if key.is_a?(String) || key.is_a?(Symbol)
            entry[:key] = key.to_sym
          elsif key.is_a?(Hash)
            entry = key
          end



          entry[:name] ||= (I18n.t("#{i18n_root}.#{entry[:key]}", raise: true) rescue entry[:key].to_s.humanize)
          entry[:url] ||= send("#{entry[:key]}_path")

          if (children_class = entry[:children_class])
            scopes = %w(published sort_by_position sort_by_sorting_position).select{|s| children_class.respond_to?(s) }

            children = children_class.all
            if scopes.any?
              scopes.each do |s|
                children = children.send(s)
              end
            end

            entry[:children] = children
          end


          #active = params[:route_name].to_s == key

          h[entry[:key]] = entry


          if check_for_active
            active = controller_name == key || (action_name == key && controller_name == "pages") || params[:route_name].to_s == key
            entry[:active] = active
          end

        end

        h
      end

      def footer_menu
        menu
      end

      def additional_links
        menu(%w(terms_of_use privacy_policy career sitemap), "additional_links")
      end


    end
  end
end