<div class="visible-when-content-ready pl-0 col-auto {% if (settings.filters_desktop_modal and not has_filters_available) or not settings.filters_desktop_modal %}d-md-none{% endif %}">
   {% if products %}
    <a href="#" class="js-modal-open js-fullscreen-modal-open btn btn-default btn-medium form-select" data-toggle="#nav-filters" data-modal-url="modal-fullscreen-filters" data-component="filter-button">
        <div class="row align-items-center">
            <div class="col font-weight-bold">
                {{ 'Filtrar' | t }}
            </div>
            <div class="col text-right">
                <svg class="icon-inline"><use xlink:href="#filter"/></svg>
            </div>
        </div>
    </a>
    {% endif %}
    {% embed "snipplets/modal.tpl" with{modal_id: 'nav-filters', modal_class: 'filters', modal_position: 'right', modal_position_desktop: right, modal_transition: 'slide', modal_header_title: true, modal_width: 'docked-md', modal_mobile_full_screen: 'true' } %}
        {% block modal_head %} {{'Filtros ' | translate }}{% endblock %}
        {% block modal_body %}
            <div class="d-block d-md-none">
                <div class="subtitle mb-2">{{ 'Ordenar por' | translate }}</div>
                {{ component(
                    'sort-by',{
                        label: false,
                        sort_by_classes: {
                            select_group: "form-group-small d-inline-block w-auto mb-0",
                            select: "btn btn-default btn-medium text-left font-weight-bold ",
                            select_svg: "icon-inline icon-w-14 icon-lg icon-rotate-90",
                        },
                        select_svg_id: 'chevron'
                    }) 
                }}
                <div class="divider mt-3 pt-2 mb-4"></div>
            </div>
            {% if has_filters_available %}
                {% if filter_categories is not empty %}
                    {% include "snipplets/grid/categories.tpl" with {modal: true} %}
                {% endif %}
                {% if product_filters is not empty %}
                    {% include "snipplets/grid/filters.tpl" with {modal: true} %}
                {% endif %}
                <div class="js-filters-overlay filters-overlay" style="display: none;">
                    <div class="filters-updating-message">
                        <span class="js-applying-filter h5 mr-2" style="display: none;">{{ 'Aplicando filtro' | translate }}</span>
                        <span class="js-removing-filter h5 mr-2" style="display: none;">{{ 'Borrando filtro' | translate }}</span>
                        <svg class="icon-inline h5 icon-spin svg-icon-text"><use xlink:href="#spinner-third"/></svg>
                    </div>
                </div>
                <div class="js-sorting-overlay filters-overlay" style="display: none;">
                    <div class="filters-updating-message">
                        <span class="h5 mr-2">{{ 'Ordenando productos' | translate }}</span>
                        <span>
                            <svg class="icon-inline h5 icon-spin svg-icon-text"><use xlink:href="#spinner-third"/></svg>
                        </span>
                    </div>
                </div>
            {% endif %}
        {% endblock %}
    {% endembed %}
</div>