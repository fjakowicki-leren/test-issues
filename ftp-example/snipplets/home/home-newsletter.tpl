{% set newsletter_image = "home_news_image.jpg" | has_custom_image %}
{% set newsletter_mobile_image = "home_news_image_mobile.jpg" | has_custom_image %}
{% set newsletter_images = newsletter_image or newsletter_mobile_image %}

<section class="js-home-newsletter-container section-newsletter-home {% if settings.home_news_colors %}section-newsletter-home-colors{% endif %} {% if newsletter_images %}section-newsletter-home-images{% endif %} {% if settings.home_order_position_16 == 'newsletter' %}mb-0{% endif %} position-relative overflow-none visible-when-content-ready" data-store="home-newsletter">

	{{ component('nubesdk-slot', { type: 'before_section_newsletter' }) }}

	<div class="container-fluid">
		<div class="js-home-newsletter-form row justify-content-center {% if settings.home_news_align == 'center' %}text-center{% endif %}">
			<div class="col-md-6">
				{% include "snipplets/newsletter.tpl" with {
					home_newsletter: true,
					form_data_store: 'home-newsletter-form',
				} %}
			</div>
		</div>
	</div>
	{% if newsletter_images or params.preview %}
		<div class="js-home-newsletter-image-container" {% if not (newsletter_image or newsletter_mobile_image) %} style="display:none;"{% endif %}>
			<img {% if newsletter_image %}src="{{ 'images/empty-placeholder.png' | static_url }}" data-srcset='{{ "home_news_image.jpg" | static_url | settings_image_url('large') }} 480w, {{ "home_news_image.jpg" | static_url | settings_image_url('huge') }} 640w, {{ "home_news_image.jpg" | static_url | settings_image_url('original') }} 1024w, {{ "home_news_image.jpg" | static_url | settings_image_url('1080p') }} 1920w'{% endif %} class='js-home-newsletter-image lazyload background-image fade-in {% if newsletter_mobile_image %}d-none d-md-block{% endif %}'{% if not newsletter_image %} style="display: none;"{% endif %}/>
			<img {% if newsletter_mobile_image %}src="{{ 'images/empty-placeholder.png' | static_url }}" data-srcset='{{ "home_news_image_mobile.jpg" | static_url | settings_image_url('large') }} 480w, {{ "home_news_image_mobile.jpg" | static_url | settings_image_url('huge') }} 640w, {{ "home_news_image_mobile.jpg" | static_url | settings_image_url('original') }} 1024w, {{ "home_news_image_mobile.jpg" | static_url | settings_image_url('1080p') }} 1920w' {% endif %} class="js-home-newsletter-image-mobile lazyload background-image fade-in {% if newsletter_image %}d-block d-md-none{% endif %}"{% if not newsletter_mobile_image %} style="display: none;"{% endif %}/>
		</div>
	{% endif %}

	{{ component('nubesdk-slot', { type: 'after_section_newsletter' }) }}
	
</section>
