{% set has_filters_available = products and has_filters_enabled and (filter_categories is not empty or product_filters is not empty) %}

{# Only remove this if you want to take away the theme onboarding advices #}
{% set show_help = not has_products %}
{% paginate by 12 %}

{% if not show_help %}

{% set category_banner = (category.images is not empty) or ("banner-products.jpg" | has_custom_image) %}
{% if category_banner %}
    {% include 'snipplets/category-banner.tpl' %}
{% endif %}
<section class="container-fluid mt-3 d-md-none">
	{% include "snipplets/breadcrumbs.tpl" %}
</section>

{% set desktop_category_controls_transparent = settings.filters_desktop_modal and settings.head_fix_desktop and settings.head_transparent and settings.head_transparent_type == 'all' %}

<section class="js-category-controls-prev category-controls-sticky-detector"></section>
<section class="js-category-controls {% if desktop_category_controls_transparent %}js-category-controls-transparent-md category-controls-transparent-md{% endif %} category-controls {% if not settings.filters_desktop_modal %}position-relative-md{% endif %} container-fluid visible-when-content-ready">
	<div class="row align-items-center">
		<div class="col">
			<div class="row align-items-center">
				<div class="col-auto">
					<div class="category-breadcrumbs-container d-none d-md-block">
						{% include "snipplets/breadcrumbs.tpl" %}
					</div>
					{% embed "snipplets/page-header.tpl" with {'breadcrumbs': false} %}
					    {% block page_header_text %}{{ category.name }}{% endblock page_header_text %}
					{% endembed %}
				</div>
				<div class="visible-when-content-ready col text-right d-none d-md-block">
					{% include "snipplets/grid/filters.tpl" with {applied_filters: true} %}
				</div>
			</div>
		</div>
		<div class="col-12 col-md-auto d-none d-md-block">
			{% if products %}
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
			{% endif %}
		</div>
		{% include 'snipplets/grid/filters-modals.tpl' %}
	</div>
</section>
{% if category.description %} 
	<p class="mt-2 mb-3 mt-md-0 mb-md-4 container-fluid">{{ category.description }}</p> 
{% endif %}
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
{% elseif show_help %}
	{# Category Placeholder #}
	{% include 'snipplets/defaults/show_help_category.tpl' %}
{% endif %}