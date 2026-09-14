{% paginate by 12 %}
{% set has_filters_available = products and has_filters_enabled and product_filters is not empty %}

	{% embed "snipplets/page-header.tpl" with { breadcrumbs: false, page_header_class:'mb-0' }  %}
		{% block page_header_text %}{{ 'Resultados de búsqueda' | translate }}{% endblock page_header_text %}
	{% endembed %}

	{% if products %}
		<div class="container-fluid d-md-none" >
			<h2 class="h6 mt-2 mb-3">
				{{ "Mostrando los resultados para" | translate }}<span class="ml-2">"{{ query }}"</span>
			</h2>
		</div>
	{% endif %}
	
<section class="js-category-controls-prev category-controls-sticky-detector"></section>	

<section class="js-category-controls {% if desktop_category_controls_transparent %}js-category-controls-transparent-md category-controls-transparent-md{% endif %} category-controls {% if not settings.filters_desktop_modal %}position-relative-md{% endif %} container-fluid visible-when-content-ready">
	<div class="row align-items-center justify-content-end">
		{% if products %}
		<div class="col pl-3 d-none d-md-block" >
			<h2 class="h6 mt-2">
				{{ "Mostrando los resultados para" | translate }}<span class="ml-2">"{{ query }}"</span>
			</h2>
		</div>
		{% endif %}
		{% if search_filter %}
			<div class="col d-none d-sm-block">
				<div class="visible-when-content-ready col text-right d-none d-md-block">
					{% include "snipplets/grid/filters.tpl" with {applied_filters: true} %}
				</div>
			</div>
			<div class="col-12 col-md-auto d-none d-md-block">
				{% if products %}
					{{ component(
						'sort-by',{
							label: false,
                            sort_by_classes: {
                                container: 'col-12 col-md-auto d-none d-md-block',
                                select_group: "form-group-small d-inline-block w-auto mb-0",
                                select: "btn btn-default btn-medium text-left font-weight-bold ",
                                select_svg: "icon-inline icon-w-14 icon-lg icon-rotate-90",
                            },
                            select_svg_id: 'chevron'
                        }) 
                    }}
				{% endif %}
			</div>
			{% include 'snipplets/grid/filters-modals.tpl' %}
		{% endif %}
	</div>
</section>

<div class="container-fluid visible-when-content-ready d-md-none">
	{% include "snipplets/grid/filters.tpl" with {mobile: true, applied_filters: true} %}
</div>


<section class="js-category-body category-body mt-2 mt-md-{% if settings.filters_desktop_modal or (not settings.filters_desktop_modal and not has_filters_available) %}0{% else %}4 pt-md-1{% endif %}">
	<div class="container-fluid">
		<div class="row">
			{% include "snipplets/grid/filters-sidebar.tpl" %}
			{% include 'snipplets/grid/products-list.tpl' %}
		</div>
	</div>
</section>