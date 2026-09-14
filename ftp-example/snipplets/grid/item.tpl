{# /*============================================================================
  #Item grid
==============================================================================*/

#Properties

#Slide Item

#}

{% set slide_item = slide_item | default(false) %}
{% set columns_desktop = template == 'home' ? section_columns_desktop : settings.grid_columns_desktop %}
{% set columns_mobile = template == 'home' ? section_columns_mobile : settings.grid_columns_mobile %}
{% set theme_editor = params.preview %}
{% set appear_transition = appear_transition ?? true %}
{% set inline_quick_shop = settings.quick_shop and settings.quick_shop_type == 'inline' %}

{# Subscription only detection #}
{% set is_subscription_only = product.isSubscriptionOnly() %}

{# Item image slider #}

{% set show_image_slider = 
    (template == 'category' or template == 'search')
    and settings.product_item_slider 
    and not reduced_item
    and not slide_item
    and not has_filters
    and product.other_images
%}

{% if show_image_slider %}
    {% set slider_controls_container_class = 'item-slider-controls-container svg-square svg-icon-text d-none d-md-block' %}
    {% set control_next_svg_id = 'chevron' %}
    {% set control_prev_svg_id = 'chevron' %}
{% endif %}

{# Secondary images #}

{% set show_secondary_image = settings.product_hover %}

{% if slide_item %}
    <div class="swiper-slide">
{% endif %}
    <div class="js-item-product{% if slide_item %} js-item-slide p-0{% endif %}{% if not slide_item %} col-{% if columns_mobile == 1 %}12{% elseif columns_mobile == 2 %}6{% else %}4{% endif %} col-md-{% if columns_desktop == 2 %}6{% elseif columns_desktop == 3 %}4{% else %}3{% endif %}{% endif %} item item-product {% if reduced_item %}item-product-reduced{% endif %} grid-item {% if reduced_item %}item-product-reduced{% endif %}" data-product-type="list" data-product-id="{{ product.id }}" data-store="product-item-{{ product.id }}" data-component="product-list-item" data-component-value="{{ product.id }}"{% if appear_transition %} data-transition="fade-in-up"{% endif %}>
        {% if (settings.quick_shop or settings.product_color_variants) and not reduced_item %}
            <div class="js-product-container js-quickshop-container{% if product.variations %} js-quickshop-has-variants{% endif %} position-relative" data-variants="{{ product.variants_object | json_encode }}" data-quickshop-id="quick{{ product.id }}">
        {% endif %}
        {% set product_url_with_selected_variant = has_filters ?  ( product.url | add_param('variant', product.selected_or_first_available_variant.id)) : product.url  %}

        {# Set how much viewport space the images will take to load correct image #}

        {% if params.preview %}
            {% set mobile_image_viewport_space = '100' %}
            {% set desktop_image_viewport_space = '50' %}
        {% else %}
            {% if columns_mobile == 3 %}
                {% set mobile_image_viewport_space = '33' %}
            {% elseif columns_mobile == 2 %}
                {% set mobile_image_viewport_space = '50' %}
            {% else %}
                {% set mobile_image_viewport_space = '100' %}
            {% endif %}

            {% if columns_desktop == 4 %}
                {% set desktop_image_viewport_space = '25' %}
            {% elseif columns_desktop == 3 %}
                {% set desktop_image_viewport_space = '33' %}
            {% else %}
                {% set desktop_image_viewport_space = '50' %}
            {% endif %}
        {% endif %}

        {% set image_classes = 'js-item-image lazyautosizes ' ~ (not image_priority_high ? 'lazyload') ~ ' fade-in img-absolute img-absolute-centered' %}
        {% set data_expand = show_image_slider ? '50' : '-10' %}

        {% set floating_elements %}
            {% if not reduced_item %}
                <div class="item-floating-elements">
                    {% if settings.product_color_variants %}
                        {% include 'snipplets/labels.tpl' with {color: true} %}
                    {% else %}
                        {% include 'snipplets/labels.tpl' %}
                    {% endif %}
                    {% if show_image_slider %}
                        {% set slider_pagination_two_amount_classes = product.images_count == 2 ? 'two-bullets' %}
                        <div class="js-product-item-slider-pagination-container-private item-slider-pagination-container d-md-none {{ slider_pagination_two_amount_classes }}">
                            <div class="js-product-item-slider-pagination-private item-slider-pagination swiper-pagination" data-item-slider-id="{{ product.id }}"></div>
                        </div>
                    {% endif %}
                </div>
            {% endif %}
        {% endset %}

        {{ component(
            'product-item-image', {
                image_lazy: true,
                image_lazy_js: true,
                image_thumbs: ['small', 'medium', 'large', 'huge', 'original'],
                image_data_expand: data_expand,
                image_secondary_data_sizes: 'auto',
                image_sizes: '(max-width: 768px)' ~ mobile_image_viewport_space ~ 'vw, (min-width: 769px)' ~ desktop_image_viewport_space ~ 'vw',
                secondary_image: show_secondary_image,
                slider: show_image_slider,
                slider_pagination: false,
                placeholder: true,
                image_priority_high: image_priority_high,
                custom_content: floating_elements,
                product_item_image_classes: {
                    image_container: 'item-image' ~ (columns == 1 ? ' item-image-big'),
                    image_padding_container: 'position-relative d-block',
                    image: image_classes,
                    image_featured: 'item-image-featured',
                    image_secondary: 'item-image-secondary',
                    slider_container: 'swiper-container position-absolute h-100 w-100',
                    slider_wrapper: 'swiper-wrapper',
                    slider_slide: 'swiper-slide item-image-slide',
                    slider_control: 'icon-inline icon-lg',
                    slider_control_prev_container: 'swiper-button-prev ' ~ slider_controls_container_class,
                    slider_control_prev: 'icon-flip-horizontal',
                    slider_control_next_container: 'swiper-button-next ' ~ slider_controls_container_class,
                    more_images_message: 'item-more-images-message',
                    placeholder: 'placeholder-fade',
                },
                control_next_svg_id: control_next_svg_id,
                control_prev_svg_id: control_prev_svg_id,
            })
        }}

        {% if 
            ((settings.quick_shop and not product.isSubscribable()) or settings.product_color_variants)
            and product.available 
            and product.display_price 
            and product.variations 
            and not reduced_item 
        %}

            {# Hidden product form to update item image and variants: Also this is used for quickshop popup #}
            {% if inline_quick_shop %}
                <div class="position-relative">
            {% endif %}
                <div class="js-item-variants {% if inline_quick_shop %}item-variants item-variants-hidden transition-soft{% else %}hidden{% endif %}">
                    <form class="js-product-form" method="post" action="{{ store.cart_url }}">
                        <input type="hidden" name="add_to_cart" value="{{product.id}}" />
                        {% if product.variations %}
                            {% include "snipplets/product/product-variants.tpl" with {quickshop: true} %}
                        {% endif %}
                        {% set state = store.is_catalog ? 'catalog' : (product.available ? product.display_price ? 'cart' : 'contact' : 'nostock') %}
                        {% set texts = {'cart': "Agregar al carrito", 'contact': "Consultar precio", 'nostock': "Sin stock", 'catalog': "Consultar"} %}

                        {# Add to cart CTA #}

                        <input type="submit" class="js-addtocart js-prod-submit-form btn btn-primary w-100 mb-2 {{ state }}" value="{{ texts[state] | translate }}" {% if state == 'nostock' %}disabled{% endif %} />

                        {# Fake add to cart CTA visible during add to cart event #}

                        {% include 'snipplets/placeholders/button-placeholder.tpl' with {custom_class: "mb-2"} %}
                    </form>
                </div>
            {% if inline_quick_shop %}
                </div>
            {% endif %}

        {% endif %}
        <div class="js-item-description item-description" data-store="product-item-info-{{ product.id }}">
            <a href="{{ product_url_with_selected_variant }}" title="{{ product.name }}" aria-label="{{ product.name }}" class="item-link{% if inline_quick_shop and not reduced_item %} item-link-quickshop{% endif %}">

                {{ component('nubesdk-slot', { type: "before_product_grid_item_name" }) }}

                <div class="js-item-name item-name mb-2 {% if columns_mobile == 3 %}d-none d-md-block{% endif %}" data-store="product-item-name-{{ product.id }}">{{ product.name }}</div>

                {{ component('nubesdk-slot', { type: "after_product_grid_item_name" }) }}

                {% if settings.product_color_variants and not reduced_item %}
                    {% if columns_mobile == 3 or theme_editor %}
                        <span class="js-item-colors-container {% if columns_mobile == 3 %}d-none d-md-block{% endif %}">
                    {% endif %}
                        {% include 'snipplets/grid/item-colors.tpl' %}
                    {% if columns_mobile == 3 or theme_editor %}
                        </span>
                    {% endif %}
                {% endif %}

                {{ component('nubesdk-slot', { type: "before_product_grid_item_price" }) }}

                {% if product.display_price %}
                    {% if is_subscription_only %}
                        {# Subscription only products: use subscription-price component with product_list location #}
                        {{ component('subscriptions/subscription-price', {
                            location: 'product_list',
                            subscription_classes: {
                                container: 'item-price-container {% if columns_mobile == 3 %}mb-0 mb-md-2{% else %}mb-2{% endif %}',
                                price_compare: 'price-compare',
                                price_with_subscription: 'item-price',
                            },
                        }) }}
                    {% else %}
                        {# Normal products: original price display #}
                        <div class="js-item-price-container item-price-container {% if columns_mobile == 3 %}mb-0 mb-md-2{% else %}mb-2{% endif %}" data-store="product-item-price-{{ product.id }}">
                            {% if not reduced_item %}
                                <span class="js-compare-price-display price-compare {% if columns_mobile == 3 and product.compare_at_price %}d-none d-md-inline-block{% endif %}" {% if not product.compare_at_price or not product.display_price %}style="display:none;"{% else %}style="display:inline-block;"{% endif %} data-price-compare-visibility="{{ product.compare_at_price ? 'true' : 'false' }}">
                                    {{ product.compare_at_price | money_nocents }}
                                </span>
                            {% endif %}
                            <span class="js-price-display item-price" data-product-price="{{ product.price }}">
                                {{ product.price | money_nocents }}
                            </span>
                            {{ component('payment-discount-price', {
                                    visibility_condition: settings.payment_discount_price and not reduced_item,
                                    location: 'product',
                                    container_classes: "font-small mt-1",
                                }) 
                            }}
                        </div>
                    {% endif %}
                {% endif %}

                {{ component('nubesdk-slot', { type: "after_product_grid_item_price" }) }}

                {% if settings.product_installments and not reduced_item %}
                    {% if columns_mobile == 3 or theme_editor %}
                        <span class="js-item-installments-container d-none d-md-block">
                    {% endif %}
                        {{ component('installments', {'location' : 'product_item', container_classes: { installment: "item-installments"}}) }}
                    {% if columns_mobile == 3 or theme_editor %}
                        </span>
                    {% endif %}
                {% endif %}

                {% if not reduced_item %}

                    {{ component('subscriptions/subscription-message', {
                        subscription_classes: {
                            container: 'font-small mt-2 ' ~ (columns_mobile == 3 ? 'd-none d-md-block'),
                        },
                    }) }}

                {% endif %}
            </a>
            {% if settings.quick_shop and not reduced_item %}
                <div class="js-item-quickshop item-actions{% if inline_quick_shop %}-inline{% else %} mt-3{% endif %} {% if columns_mobile == 3 %}d-none d-md-block{% endif %}">
                    
                    {% if product.available and product.display_price %}

                        {% set quickshop_button_classes = inline_quick_shop ? 'item-btn-quickshop' : 'btn btn-primary btn-small item-btn-cart' %}
                    
                        {% set state = store.is_catalog ? 'catalog' : (product.available ? product.display_price ? 'cart' : 'contact' : 'nostock') %}
                        {% set texts = {'cart': "Agregar al carrito", 'contact': "Consultar precio", 'nostock': "Sin stock", 'catalog': "Consultar"} %}
                        
                        {% if product.isSubscribable() %}

                            {# Product with subscription will link to the product page #}

                            {% set button_text = is_subscription_only ? ('our_components.subscriptions.subscribe' | tt) : texts[state] %}
                            {% set button_title = is_subscription_only ? ('our_components.subscriptions.subscribe' | tt) ~ ' ' ~ product.name : ('Compra rápida de' | translate) ~ ' ' ~ product.name %}
                            <a href="{{ product_url_with_selected_variant }}" class="{{ quickshop_button_classes }}" title="{{ button_title }}" aria-label="{{ button_title }}">
                                {% if inline_quick_shop %}
                                    <svg class="icon-inline icon-lg svg-icon-text"><use xlink:href="#bag"/></svg>
                                {% else %}
                                    {{ button_text | translate }}
                                {% endif %}
                            </a>

                        {% else %}
                            {% if product.variations %}
                                
                                {% if inline_quick_shop %}
                                
                                    {# Open quickshop inline if has variants #}

                                    <button type="button" class="js-item-buy-open {{ quickshop_button_classes }}" title="{{ 'Compra rápida de' | translate }} {{ product.name }}" aria-label="{{ 'Compra rápida de' | translate }} {{ product.name }}">
                                        <svg class="icon-inline icon-lg svg-icon-text"><use xlink:href="#bag"/></svg>
                                    </button>
                                    <button type="button" class="js-item-buy-close {{ quickshop_button_classes }}" aria-label="{{ 'Cerrar compra rápida' | translate }}" style="display: none;">
                                        <svg class="icon-inline icon-lg svg-icon-text"><use xlink:href="#times"/></svg>
                                    </button>
                                {% else %}
                                    {# Open quickshop popup if has variants #}

                                    <a data-toggle="#quickshop-modal" data-modal-url="modal-fullscreen-quickshop" href="#" class="js-quickshop-modal-open {% if slide_item %}js-quickshop-slide{% endif %} js-modal-open js-fullscreen-modal-open {{ quickshop_button_classes }}" title="{{ 'Compra rápida de' | translate }} {{ product.name }}" aria-label="{{ 'Compra rápida de' | translate }} {{ product.name }}" data-component="product-list-item.add-to-cart" data-component-value="{{product.id}}">{{ 'Agregar al carrito' | translate }}</a>
                                {% endif %}
                            {% else %}
                                <form class="js-product-form d-inline-block" method="post" action="{{ store.cart_url }}">
                                    <input type="hidden" name="add_to_cart" value="{{product.id}}" />
                                    {% set state = store.is_catalog ? 'catalog' : (product.available ? product.display_price ? 'cart' : 'contact' : 'nostock') %}
                                    {% set texts = {'cart': "Agregar al carrito", 'contact': "Consultar precio", 'nostock': "Sin stock", 'catalog': "Consultar"} %}
                                    {% set button_placeholder_icon = inline_quick_shop ? true : false %}
                                    {% set button_placeholder_classes = inline_quick_shop ? 'btn-quickshop item-btn-quickshop' : 'btn-small mb-2 item-btn-cart' %}

                                    {% if inline_quick_shop %}
                                        <div class="js-item-submit-container {{ quickshop_button_classes }}">
                                            <input type="submit" class="js-addtocart js-prod-submit-form btn {{ state }}" value="{{ texts[state] | translate }}" alt="{{ texts[state] | translate }}" {% if state == 'nostock' %}disabled{% endif %} />
                                            <svg class="icon-inline icon-lg svg-icon-text item-btn-quickshop-icon"><use xlink:href="#bag"/></svg>
                                        </div>
                                    {% else %}
                                        <input type="submit" class="js-addtocart js-prod-submit-form {{ quickshop_button_classes }} mb-2 {{ state }}" value="{{ texts[state] | translate }}" {% if state == 'nostock' %}disabled{% endif %} data-component="product-list-item.add-to-cart" data-component-value="{{ product.id }}"/>
                                    {% endif %}

                                    {# Fake add to cart CTA visible during add to cart event #}

                                    {% include 'snipplets/placeholders/button-placeholder.tpl' with {custom_class: button_placeholder_classes, direct_add: true, icon: button_placeholder_icon} %}
                                </form>
                            {% endif %}
                        {% endif %}
                    {% endif %}
                </div>
            {% endif %}
        </div>
        {% if (settings.quick_shop or settings.product_color_variants) and not reduced_item %}
            </div>{# This closes the quickshop tag #}
        {% endif %}

        {# Structured data to provide information for Google about the product content #}
        {{ component('structured-data', {'item': true}) }}
    </div>
{% if slide_item %}
    </div>
{% endif %}