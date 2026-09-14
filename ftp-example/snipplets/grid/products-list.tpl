{% set noFilterResult = "No tenemos resultados para tu búsqueda. Por favor, intentá con otros filtros." %}

<div class="col pl-0" data-store="category-grid-{{ category.id }}">
    {% if products %}
        <div class="js-product-table row">
            {% include 'snipplets/product_grid.tpl' %}
        </div>
        {% include "snipplets/grid/pagination.tpl" with {infinite_scroll: true} %}
    {% else %}
        <h2 class="h6 text-center mb-5" data-component="filter.message">
            {% if template =='search' %}
                {{ (has_applied_filters and query) or has_applied_filters  ? ("No tenemos resultados para tu búsqueda. Por favor, intentá con otros filtros."| translate): ("Escribilo de otra forma y volvé a intentar." | translate) }}
            {% elseif template == 'category' %}
                {{(has_filters_enabled ? noFilterResult : "Próximamente") | translate}}
            {% endif %}
        </h2>
    {% endif %}
</div>