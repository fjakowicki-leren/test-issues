{% if (settings.brands and settings.brands is not empty) or params.preview %}
	<div class="js-section-brands home-brands-bar{% if not settings.brands_title %} home-brands-bar--no-title{% endif %}">
		{% if settings.brands_title %}
			<div class="container">
				<h2 class="js-brands-title h5 section-title mb-0 text-center home-brands-bar__title">{{ settings.brands_title }}</h2>
			</div>
		{% else %}
			<h2 class="js-brands-title h5 section-title mb-0 text-center home-brands-bar__title" style="display:none"></h2>
		{% endif %}
		<div class="home-brands-bar__track px-2 px-md-5 py-md-2 position-relative">
			<div class="js-swiper-brands brand-swiper swiper-container">
				<div class="js-swiper-brands-wrapper swiper-wrapper">
					{% for slide in settings.brands %}
						{% set brand_label = slide.title | default(store.name) %}
						<div class="swiper-slide home-brands-bar__slide">
							{% if slide.link %}
								<a href="{{ slide.link | setting_url }}" class="home-brands-bar__item" title="{{ brand_label }}" aria-label="{{ brand_label }}">
							{% else %}
								<div class="home-brands-bar__item">
							{% endif %}
								{% if slide.image %}
									<img src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{{ slide.image | static_url | settings_image_url('large') }}" class="lazyload brand-image home-brands-bar__image" alt="{{ brand_label }}">
								{% endif %}
								{% if slide.title %}
									<span class="home-brands-bar__name">{{ slide.title }}</span>
								{% endif %}
							{% if slide.link %}
								</a>
							{% else %}
								</div>
							{% endif %}
						</div>
					{% endfor %}
				</div>
			</div>
			<div class="js-swiper-brands-prev home-brands-bar__nav home-brands-bar__nav--prev swiper-button-prev d-none d-md-flex svg-icon-text">
				<svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#chevron"/></svg>
			</div>
			<div class="js-swiper-brands-next home-brands-bar__nav home-brands-bar__nav--next swiper-button-next d-none d-md-flex svg-icon-text">
				<svg class="icon-inline icon-lg"><use xlink:href="#chevron"/></svg>
			</div>
		</div>
	</div>
{% endif %}
