{% set has_filters_available = products and has_filters_enabled and product_filters is not empty %}
{% set search_page_filters = template == 'search' and search_filter %}
{% set category_page = template == 'category' %}
{% set show_filters = products or has_filters_available %}

{% if  show_filters and (category_page or search_page_filters) and not settings.filters_desktop_modal %} 
    <div class="filters-sidebar col col-md-2 d-none d-md-block visible-when-content-ready">
        {% if products %}
            {% if filter_categories is not empty %}
                {% include "snipplets/grid/categories.tpl" with {modal: false} %}
            {% endif %}
            {% if product_filters is not empty %}	   
                {% include "snipplets/grid/filters.tpl" %}
            {% endif %}
        {% endif %}
    </div>
{% endif %}
    