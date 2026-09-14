{# /*============================================================================
  #Home featured grid
==============================================================================*/

#Properties

#Featured Slider

#}

{% set featured_products = featured_products | default(false) %}
{% set new_products = new_products | default(false) %}
{% set sale_products = sale_products | default(false) %}

{# Check if slider is used #}

{% set has_featured_products_and_slider = featured_products and settings.featured_products_format != 'grid' %}
{% set has_new_products_and_slider = new_products and settings.new_products_format != 'grid' %}
{% set has_sale_products_and_slider = sale_products and settings.sale_products_format != 'grid' %}
{% set use_slider = has_featured_products_and_slider or has_new_products_and_slider or has_sale_products_and_slider %}
{% set section_columns_grid_mobile = settings.grid_columns_mobile %}
{% set section_columns_grid_slider_mobile = section_columns_grid_mobile == '1' ? '1.15' : section_columns_grid_mobile == '2' ? '2.25' : '3.25' %}

{% if featured_products %}
    {% set sections_products = sections.primary.products %}
    {% set section_name = 'primary' %}
    {% set section_title = settings.featured_products_title %}
    {% set section_button = settings.featured_products_button %}
    {% set section_button_url = settings.featured_products_button_url %}
    {% set section_format = settings.featured_products_format %}
    {% set section_id = 'featured' %}
    {% set section_grid_desktop = settings.featured_products_desktop == 'default' ? 'true' : 'false' %}
    {% set section_grid_mobile = settings.featured_products_mobile == 'default' ? 'true' : 'false' %}
    {% set section_columns_desktop = settings.featured_products_desktop == 'default' ? settings.grid_columns_desktop : settings.featured_products_desktop %}
    {% set section_columns_mobile = settings.featured_products_mobile == 'default' ? settings.grid_columns_mobile : settings.featured_products_mobile %}
{% endif %}
{% if new_products %}
    {% set sections_products = sections.new.products %}
    {% set section_name = 'new' %}
    {% set section_title = settings.new_products_title %}
    {% set section_button = settings.new_products_button %}
    {% set section_button_url = settings.new_products_button_url %}
    {% set section_format = settings.new_products_format %}
    {% set section_id = 'new' %}
    {% set section_columns_desktop = settings.new_products_desktop %}
    {% set section_columns_mobile = settings.new_products_mobile %}
    {% set section_grid_desktop = settings.new_products_desktop == 'default' ? 'true' : 'false' %}
    {% set section_grid_mobile = settings.new_products_mobile == 'default' ? 'true' : 'false' %}
    {% set section_columns_desktop = settings.new_products_desktop == 'default' ? settings.grid_columns_desktop : settings.new_products_desktop %}
    {% set section_columns_mobile = settings.new_products_mobile == 'default' ? settings.grid_columns_mobile : settings.new_products_mobile %}
{% endif %}
{% if sale_products %}
    {% set sections_products = sections.sale.products %}
    {% set section_name = 'sale' %}
    {% set section_title = settings.sale_products_title %}
    {% set section_button = settings.sale_products_button %}
    {% set section_button_url = settings.sale_products_button_url %}
    {% set section_format = settings.sale_products_format %}
    {% set section_id = 'sale' %}
    {% set section_grid_desktop = settings.sale_products_desktop == 'default' ? 'true' : 'false' %}
    {% set section_grid_mobile = settings.sale_products_mobile == 'default' ? 'true' : 'false' %}
    {% set section_columns_desktop = settings.sale_products_desktop == 'default' ? settings.grid_columns_desktop : settings.sale_products_desktop %}
    {% set section_columns_mobile = settings.sale_products_mobile == 'default' ? settings.grid_columns_mobile : settings.sale_products_mobile %}
{% endif %}

{% set section_columns_slider_mobile = section_columns_mobile == '1' ? '1.15' : section_columns_mobile == '2' ? '2.25' : '3.25' %}
{% set has_section_button = section_button and section_button_url %}

<div class="js-products-{{ section_id }}-container container-fluid">
    <div class="row">
        <div class="home-products-header col-12" {% if not section_title and not has_section_button %}style="display: none;"{% endif %}>
            <h2 class="js-products-{{ section_id }}-title home-products-header__title section-title h5 mb-0" {% if not section_title %}style="display: none;"{% endif %}>
                {{ section_title }}
            </h2>
            {% if has_section_button %}
                <a href="{{ section_button_url | setting_url }}" class="js-products-{{ section_id }}-button btn btn-primary btn-small home-products-header__btn">{{ section_button }}</a>
            {% endif %}
        </div>
        <div class="js-products-{{ section_id }}-col col-12 {% if use_slider %}p-0{% else %}pl-0{% endif %}">
            {% if use_slider %}
                <div class="js-swiper-{{ section_id }} swiper-container">
            {% endif %}
                    <div class="js-products-{{ section_id }}-grid js-products-home-grid  {% if use_slider %}swiper-wrapper{% else %}row{% endif %}" 
                    data-desktop-columns="{{ section_columns_desktop }}" 
                    data-mobile-columns="{{ section_columns_mobile }}" 
                    data-desktop-grid="{{ section_grid_desktop }}" 
                    data-desktop-grid-columns="{{ settings.grid_columns_desktop }}" 
                    data-mobile-grid="{{ section_grid_mobile }}" 
                    data-mobile-grid-columns="{{ settings.grid_columns_mobile }}" 
                    data-mobile-grid-slider-columns="{{ section_columns_grid_slider_mobile }}" 
                    data-mobile-slider-columns="{{ section_columns_slider_mobile }}" 
                    data-format="{{ section_format }}" 
                    data-section-id="{{ section_id }}">
                        {% for product in sections_products %}
                            {% if use_slider %}
                                {% include 'snipplets/grid/item.tpl' with {'slide_item': true, 'section_name': section_name} %}
                            {% else %}
                                {% include 'snipplets/grid/item.tpl' %}
                            {% endif %}
                        {% endfor %}
                    </div>
            {% if use_slider %}
                </div>
            {% endif %}
        </div>
    </div>
</div>

{% if use_slider %}
    <div class="js-swiper-{{ section_id }}-prev swiper-button-prev swiper-nav-circle d-none d-md-flex" aria-label="{{ 'Anterior' | translate }}">
        <svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long-neg"/></svg>
    </div>
    <div class="js-swiper-{{ section_id }}-next swiper-button-next swiper-nav-circle d-none d-md-flex" aria-label="{{ 'Siguiente' | translate }}">
        <svg class="icon-inline icon-lg"><use xlink:href="#arrow-long-neg"/></svg>
    </div>
{% endif %}
