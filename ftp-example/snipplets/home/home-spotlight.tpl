{% set has_spotlight_image = "home_spotlight_image.jpg" | has_custom_image %}
{% set has_spotlight_illustration = "home_spotlight_illustration.jpg" | has_custom_image %}
{% set has_spotlight_text = settings.home_spotlight_title or settings.home_spotlight_text or (settings.home_spotlight_button and settings.home_spotlight_button_url) %}

{% if has_spotlight_image or has_spotlight_illustration or has_spotlight_text or params.preview %}
	<section class="section-home-spotlight home-spotlight mt-4 mt-md-5" data-store="home-spotlight">
		<div class="home-spotlight__content">
			<div class="home-spotlight__copy">
				{% if settings.home_spotlight_title %}
					<img
						class="home-spotlight__icon"
						src="{{ 'images/icono-ubicacion.svg' | static_url }}"
						alt=""
						aria-hidden="true"
					>
					<h2 class="home-spotlight__title">{{ settings.home_spotlight_title }}</h2>
				{% endif %}
				{% if settings.home_spotlight_text %}
					<p class="home-spotlight__text">{{ settings.home_spotlight_text }}</p>
				{% endif %}
				{% if has_spotlight_illustration %}
					<img
						class="home-spotlight__illustration lazyload"
						src="{{ 'images/empty-placeholder.png' | static_url }}"
						data-src="{{ 'home_spotlight_illustration.jpg' | static_url | settings_image_url('original') }}"
						alt=""
					>
				{% endif %}
				{% if settings.home_spotlight_button and settings.home_spotlight_button_url %}
					<a target="_blank" href="{{ settings.home_spotlight_button_url | setting_url }}" class="btn btn-primary home-spotlight__btn">{{ settings.home_spotlight_button }}</a>
				{% endif %}
			</div>
		</div>
		<div class="home-spotlight__media">
			{% if has_spotlight_image %}
				<img
					class="home-spotlight__image lazyload"
					src="{{ 'images/empty-placeholder.png' | static_url }}"
					data-srcset="{{ 'home_spotlight_image.jpg' | static_url | settings_image_url('large') }} 480w, {{ 'home_spotlight_image.jpg' | static_url | settings_image_url('huge') }} 640w, {{ 'home_spotlight_image.jpg' | static_url | settings_image_url('original') }} 1024w, {{ 'home_spotlight_image.jpg' | static_url | settings_image_url('1080p') }} 1920w"
					data-sizes="auto"
					alt="{{ settings.home_spotlight_title | default(store.name) }}"
				>
			{% elseif params.preview %}
				<div class="home-spotlight__image home-spotlight__image--placeholder"></div>
			{% endif %}
		</div>
	</section>
{% endif %}
