<section class="category-header section-margin">
	<div class="container-fluid">
		<div class="row align-items-center mb-md-5 mb-3">
			<div class="col">
				{% embed "snipplets/page-header.tpl" %}
					{% block page_header_text %}{{ category.name }}{% endblock page_header_text %}
				{% endembed %}
			</div>
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
		</div>
	</div>
</section>
<section class="js-category-body category-body">
	<div class="container-fluid">
		<div class="row">
			<div class="col pl-0">
				<div class="js-product-table row">
					{% include "snipplets/svg/empty-placeholders.tpl" %}
					{% include 'snipplets/defaults/help_item.tpl' with {'help_item_1': true} %}
					{% include 'snipplets/defaults/help_item.tpl' with {'help_item_2': true} %}
					{% include 'snipplets/defaults/help_item.tpl' with {'help_item_3': true} %}
					{% include 'snipplets/defaults/help_item.tpl' with {'help_item_4': true} %}
					{% include 'snipplets/defaults/help_item.tpl' with {'help_item_5': true} %}
					{% include 'snipplets/defaults/help_item.tpl' with {'help_item_6': true} %}
					{% include 'snipplets/defaults/help_item.tpl' with {'help_item_7': true} %}
					{% include 'snipplets/defaults/help_item.tpl' with {'help_item_8': true} %}
					{% include 'snipplets/defaults/help_item.tpl' with {'help_item_1': true} %}
				</div>
			</div>
		</div>
	</div>
</section>