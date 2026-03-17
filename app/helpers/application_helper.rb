module ApplicationHelper
  def nav_link_classes(path, base_classes: nil, active_classes: "underline underline-offset-8")
    classes = [ base_classes ]
    classes << active_classes if request&.path == path
    classes.compact.join(" ")
  end

  def responsive_picture_tag(sources:, fallback:, alt:, img_class: nil, picture_class: nil, loading: "lazy", fetchpriority: nil, width: nil, height: nil, sizes: nil)
    picture_options = picture_class.present? ? { class: picture_class } : {}

    content_tag(:picture, picture_options) do
      nodes = sources.map do |source|
        tag.source(
          media: source[:media],
          srcset: source[:srcset],
          type: source[:type],
          sizes: source[:sizes] || sizes
        )
      end

      nodes << image_tag(
        fallback,
        alt: alt,
        class: img_class,
        loading: loading,
        fetchpriority: fetchpriority,
        width: width,
        height: height,
        sizes: sizes
      )

      safe_join(nodes)
    end
  end

  def static_responsive_image_tag(base_name:, alt:, width:, height:, img_class: nil, picture_class: nil, loading: "lazy", fetchpriority: nil, sizes: nil)
    responsive_picture_tag(
      sources: [
        { media: "(max-width: 639px)", srcset: "/optimized/#{base_name}-mobile.webp", type: "image/webp" },
        { media: "(max-width: 1023px)", srcset: "/optimized/#{base_name}-tablet.webp", type: "image/webp" },
        { media: "(min-width: 1024px)", srcset: "/optimized/#{base_name}-desktop.webp", type: "image/webp" },
        { media: "(max-width: 639px)", srcset: "/optimized/#{base_name}-mobile.jpg", type: "image/jpeg" },
        { media: "(max-width: 1023px)", srcset: "/optimized/#{base_name}-tablet.jpg", type: "image/jpeg" },
        { media: "(min-width: 1024px)", srcset: "/optimized/#{base_name}-desktop.jpg", type: "image/jpeg" }
      ],
      fallback: "/optimized/#{base_name}-desktop.jpg",
      alt: alt,
      img_class: img_class,
      picture_class: picture_class,
      loading: loading,
      fetchpriority: fetchpriority,
      width: width,
      height: height,
      sizes: sizes
    )
  end

  def product_card_image(product, width:, height:, img_class: nil, loading: "lazy")
    if product.image.attached?
      image_tag(
        product.image.variant(resize_to_limit: [width * 2, height * 2]),
        class: img_class,
        loading: loading,
        width: width,
        height: height,
        alt: "#{product.brand} #{product.name}"
      )
    else
      image_tag(
        "/placeholder-bottle.png",
        class: img_class,
        loading: loading,
        width: width,
        height: height,
        alt: "#{product.brand} #{product.name}"
      )
    end
  end

  def short_product_label(product)
    product.short_display_name
  end

  def product_featured_note(product)
    return product.featured_note if product.featured_note.present?
    return unless product.featured?

    if product.is_alcoholic?
      "Von uns empfohlen für unkomplizierte Ausschanke mit hoher Trefferquote."
    else
      "Von uns empfohlen als zugängliche alkoholfreie Option vom Fass."
    end
  end

  def page_title
    content_for(:title).presence || page_meta[:title]
  end

  def page_description
    content_for(:meta_description).presence || page_meta[:description]
  end

  def canonical_url
    return nil unless request

    "#{request.base_url}#{request.path}"
  end

  def og_image_url
    return nil unless request

    "#{request.base_url}/optimized/zapfe-hero-desktop.jpg"
  end

  def page_json_ld
    data = [
      {
        "@context": "https://schema.org",
        "@type": "WebPage",
        name: page_title,
        description: page_description,
        url: canonical_url
      }
    ]

    if controller_name == "pages" && action_name == "home"
      data << {
        "@context": "https://schema.org",
        "@type": "LocalBusiness",
        name: "Zapfe!",
        image: og_image_url,
        url: canonical_url,
        telephone: "+49 162 347 3520",
        email: "info@zapfe.jetzt",
        address: {
          "@type": "PostalAddress",
          postalCode: "79104",
          addressLocality: "Freiburg im Breisgau",
          addressCountry: "DE"
        },
        areaServed: "Freiburg im Breisgau und Umgebung",
        description: page_description
      }
    end

    if controller_name == "pages" && %w[events solutions].include?(action_name)
      data << {
        "@context": "https://schema.org",
        "@type": "Service",
        name: page_title,
        provider: {
          "@type": "LocalBusiness",
          name: "Zapfe!"
        },
        areaServed: "Freiburg im Breisgau und Umgebung",
        serviceType: "Mobile Zapfanlage und Self-Service Ausschank"
      }
    end

    if controller_name == "pages" && action_name == "calculator"
      data << {
        "@context": "https://schema.org",
        "@type": "FAQPage",
        mainEntity: [
          {
            "@type": "Question",
            name: "Gibt es eine Mindestmietdauer?",
            acceptedAnswer: {
              "@type": "Answer",
              text: "Ja, unsere Standardmindestmietdauer beträgt 4 Stunden, einschließlich Auf- und Abbauzeit."
            }
          },
          {
            "@type": "Question",
            name: "Können wir unsere eigenen Getränke wählen?",
            acceptedAnswer: {
              "@type": "Answer",
              text: "Ja. Wir bieten eine große Auswahl und können auf Wunsch Sonderwünsche prüfen."
            }
          },
          {
            "@type": "Question",
            name: "Bieten Sie Rabatte für Veranstaltungen unter der Woche an?",
            acceptedAnswer: {
              "@type": "Answer",
              text: "Ja, wir bieten Sonderkonditionen von Montag bis Donnerstag. Kontaktiere uns für Details."
            }
          }
        ]
      }
    end

    data
  end

  def main_container_classes
    if controller_name == "pages" && action_name == "home"
      "pt-14"
    else
      "min-h-[75vh] pt-14"
    end
  end

  def footer_classes
    if controller_name == "pages" && action_name == "home"
      "bg-[var(--color-zapfe-navy)] text-white"
    else
      "mt-20 bg-[var(--color-zapfe-navy)] text-white"
    end
  end

  private

  def page_meta
    key = "#{controller_name}##{action_name}"
    PageMetaCatalog.fetch(key)
  end
end
