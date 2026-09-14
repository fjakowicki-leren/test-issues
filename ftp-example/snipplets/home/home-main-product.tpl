{% if sections.featured.products %}
	{% if settings.main_product_type == 'random' %}
		{% set product_type = sections.featured.products | shuffle | take(1) %}
	{% else %}
		{% set product_type = sections.featured.products | take(1) %}
	{% endif %}

	{% for product in product_type %}
		<section id="single-product" class="js-product-detail js-product-container js-shipping-calculator-container my-5" data-variants="{{product.variants_object | json_encode }}" data-store="home-product-main">
			<div class="container">
				<div class="row justify-content-md-center">
					<div class="{% if product.media_count > 1 %}col-md-11{% else %}col-md-10{% endif %}">
						<div class="row">
							<div class="col-12 col-md-7 pl-md-0">
								{% include 'snipplets/product/product-image.tpl' with { home_main_product: true } %}
							</div>
							<div class="col" data-store="product-info-{{ product.id }}">
								<div class="js-sticky-product sticky-product">
									{% include 'snipplets/product/product-form.tpl' with { home_main_product: true } %}
									{% if product.description is not empty %}
										<div class="{% if settings.product_stock %}mt-1{% else %}mt-2{% endif %}">
											{# Product description #}
											<div class="js-product-description home-product-description user-content font-small">
												{{ product.description }}
											</div>
											<div class="js-view-description mt-3" style="display: none;">
												<div class="btn-link btn-link-primary">
													<span class="js-view-more">
														{{ "Ver más" | translate }}
														<svg class="icon-inline icon-rotate-90 ml-1"><use xlink:href="#chevron"/></svg>
													</span>
													<span class="js-view-less" style="display: none;">
														{{ "Ver menos" | translate }}
														<svg class="icon-inline icon-rotate-90-neg ml-1"><use xlink:href="#chevron"/></svg>
													</span>
												</div>
											</div>
										</div>
									{% endif %}
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</section>
	{% endfor %}
{% endif %}
