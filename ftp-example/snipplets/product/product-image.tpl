{% if home_main_product %}
	{% set show_thumbs = product.media_count > 1 %}
{% else %}
	{% set show_thumbs = not settings.scroll_product_images and (product.media_count > 1 or product.video_url) %}
{% endif %}
<div class="row" data-store="product-image-{{ product.id }}"> 
	{% if show_thumbs %}
		<div class="{% if home_main_product %}col-auto{% else %}col-2{% endif %} d-none d-md-block">
			{% if not home_main_product %}
				{# If product has more than 5 images truncate thumbs #}
				{% for media in product.media | take(5) %}
					{% include 'snipplets/product/product-image-thumbs.tpl' with {last_open_modal: product.media_count > 5} %}
				{% endfor %}
				{# Video thumb #}
				{% if product.media_count > 5 %}
					<div class="mt-2">
				{% endif %}
				{% include 'snipplets/product/product-video.tpl' with {thumb: true} %}
				{% if product.media_count > 5 %}
					</div>
				{% endif %}
			{% else %}
				<div class="product-thumbs-container position-relative">
					<div class="js-swiper-product-thumbs swiper-product-thumb"> 
						<div class="swiper-wrapper">
							{% for media in product.media %}
								<div class="swiper-slide h-auto w-auto">
									{% include 'snipplets/product/product-image-thumbs.tpl' %}
								</div>
							{% endfor %}
						</div>
					</div>
					<div class="mt-2 text-center d-none d-md-block">
						<div class="js-swiper-product-thumbs-prev swiper-button-prev swiper-product-thumb-control">
							<svg class="icon-inline icon-lg svg-icon-text icon-rotate-90-neg"><use xlink:href="#chevron"/></svg>
						</div>
						<div class="js-swiper-product-thumbs-next swiper-button-next swiper-product-thumb-control">
							<svg class="icon-inline icon-lg svg-icon-text icon-rotate-90"><use xlink:href="#chevron"/></svg>
						</div>
					</div>
				</div>
			{% endif %}

		</div>
	{% endif %}
	{% if product.media_count > 0 %}
		<div class="product-image-container {% if show_thumbs %}col-12 {% if home_main_product %}col-md{% else %}col-md-10{% endif %}{% else %}col-12{% endif %} p-0">
			<div class="js-swiper-product{% if settings.scroll_product_images and not home_main_product %} product-detail-slider{% endif %} swiper-container" data-product-images-amount="{{ product.media_count }}">

				{{ component('nubesdk-slot', { type: "product_detail_image" }) }}

				{% include 'snipplets/labels.tpl' with {'product_detail': true} %}
			    <div class="swiper-wrapper">
					{% for media in product.media %}
						{% if media.isImage %}
							<div class="js-product-slide swiper-slide slider-slide {% if home_main_product %}w-100{% endif %}" data-image="{{media.id}}" data-image-position="{{loop.index0}}">
								{% if home_main_product %}
									<div class="js-product-slide-link d-block position-relative" style="padding-bottom: {{ media.dimensions['height'] / media.dimensions['width'] * 100}}%;">
								{% else %}
									<a href="{{ media | product_image_url('original') }}" data-fancybox="product-gallery" class="js-product-slide-link d-block position-relative" style="padding-bottom: {{ media.dimensions['height'] / media.dimensions['width'] * 100}}%;">
								{% endif %}

								{% set apply_lazy_load = home_main_product or not loop.first %}

								{% if apply_lazy_load %}
									{% set product_image_src = 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==' %}
								{% else %}
									{% set product_image_src = media | product_image_url('large') %}
								{% endif %}
								
								<img 
									{% if not apply_lazy_load %}fetchpriority="high"{% endif %}
									{% if apply_lazy_load %}data-{% endif %}src="{{ product_image_src }}"
									{% if apply_lazy_load %}data-{% endif %}srcset='{{ media | product_image_url('large') }} 480w, {{  media | product_image_url('huge') }} 640w, {{  media | product_image_url('original') }} 1024w' 
									class="js-product-slide-img product-slider-image img-absolute img-absolute-centered {% if apply_lazy_load %}lazyautosizes lazyload{% endif %}" 
									{% if apply_lazy_load %}data-sizes="auto"{% endif %}
									{% if media.dimensions.width and media.dimensions.height %}width="{{ media.dimensions.width }}" height="{{ media.dimensions.height }}"{% endif %}
									{% if media.alt %}alt="{{media.alt}}"{% endif %} />

								{% if home_main_product %}
									</div>
								{% else %}
									</a>
								{% endif %}
							</div>
						{% else %}
								{% include 'snipplets/product/product-video.tpl' with {video_id: media.next_video, product_native_video: true, home_main_product: home_main_product} %}
						{% endif %}
					{% endfor %}
					{% if not home_main_product %}
						{% include 'snipplets/product/product-video.tpl' with {video_id: 'yt'} %}
					{% endif %}
				</div>
				<div class="js-swiper-product-pagination swiper-pagination"></div>
			</div>
		</div>
	{% endif %}
</div>
