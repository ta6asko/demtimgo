# frozen_string_literal: true

module Spree
  module FrontendHelper
    def spree_breadcrumbs(taxon, _separator = '', product = nil)
      return '' if current_page?('/') || taxon.nil?

      # breadcrumbs for root
      crumbs = [home_breadcrumb]

      if taxon
        # breadcrumbs for main ancestor taxon
        parent_ancestor_breadcrumb(crumbs, taxon)

        # breadcrumbs for ancestor taxons
        ancestors_breadcrumb(crumbs, taxon)

        # breadcrumbs for current taxon
        current_taxon_breadcrumb(crumbs, taxon, product)

        # breadcrumbs for product
        product_breadcrumb(crumbs, taxon, product)
      else
        # breadcrumbs for product on PDP
        crumbs << content_tag(:li, content_tag(
          :span, Spree.t(:products), itemprop: 'item'
        ) << content_tag(:meta, nil, itemprop: 'position', content: '1'), class: 'active', itemscope: 'itemscope', itemtype: 'https://schema.org/ListItem', itemprop: 'itemListElement')
      end

      crumb_list = content_tag(:ul, raw(crumbs.flatten.map(&:mb_chars).join), class: 'items')
      content_tag(:div, crumb_list, class: 'breadcrumbs')
    end

    def plp_and_carousel_image(product, _image_class = '')
      image = default_image_for_product_or_variant(product)

      image_url = if image.present?
                    main_app.url_for(image.url('plp'))
                  else
                    asset_path('noimage/plp.png')
                  end

      image_style = image&.style(:plp)

      lazy_image(
        src: image_url,
        srcset: carousel_image_source_set(image),
        alt: product.name,
        width: image_style&.dig(:width) || 278,
        height: image_style&.dig(:height) || 371,
        class: '__img o-image__img img-responsive img-clip'
      )
    end

    private

    def home_breadcrumb
      a = content_tag(:a, Spree.t(:home), href: spree.root_path)
      content_tag(:li, a, class: 'item home')
    end

    def product_breadcrumb(crumbs, taxon, product)
      return unless product

      strong = content_tag(:strong, taxon.name) unless product
      crumbs << content_tag(:li, strong, class: 'item')
    end

    def current_taxon_breadcrumb(crumbs, taxon, product)
      strong = content_tag(:strong, taxon.name) unless product
      a = content_tag(:a, taxon.name, href: seo_url(taxon, params: permitted_product_params))
      crumbs << content_tag(:li, strong || a, class: 'item')
    end

    def parent_ancestor_breadcrumb(crumbs, taxon)
      ancestors = taxon.ancestors.where(parent_id: nil)

      crumbs << ancestors.each_with_index.map do |ancestor|
        a = content_tag(:a, ancestor.name, href: seo_url(ancestor, params: permitted_product_params))
        content_tag(:li, a, class: 'item')
      end
    end

    def ancestors_breadcrumb(crumbs, taxon)
      ancestors = taxon.ancestors.where.not(parent_id: nil)

      crumbs << ancestors.each_with_index.map do |ancestor|
        a = content_tag(:a, ancestor.name, href: seo_url(ancestor, params: permitted_product_params))
        content_tag(:li, a, class: 'item')
      end
    end
  end
end
