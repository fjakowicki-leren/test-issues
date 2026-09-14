{% set has_editorial_image = "home_editorial_image.jpg" | has_custom_image %}
{% set has_editorial_text = settings.home_editorial_title or settings.home_editorial_subtitle or settings.home_editorial_text or (settings.home_editorial_button and settings.home_editorial_button_url) %}
{% set has_editorial_news = settings.home_editorial_news_title or settings.home_editorial_news_text %}
{% set has_text_sticker = "home_editorial_text_sticker.jpg" | has_custom_image %}
{% set has_news_sticker_left = "home_editorial_news_sticker_left.jpg" | has_custom_image %}
{% set has_news_sticker_left_bottom = "home_editorial_news_sticker_left_bottom.jpg" | has_custom_image %}
{% set has_news_sticker_right = "home_editorial_news_sticker_right.jpg" | has_custom_image %}

{% if has_editorial_image or has_editorial_text or has_editorial_news or params.preview %}
	<section class="section-home-editorial home-editorial mt-4 mt-md-5" data-store="home-editorial">
		<div class="home-editorial__top">
			<div class="home-editorial__media">
				{% if has_editorial_image %}
					<img
						class="home-editorial__image lazyload"
						src="{{ 'images/empty-placeholder.png' | static_url }}"
						data-srcset="{{ 'home_editorial_image.jpg' | static_url | settings_image_url('large') }} 480w, {{ 'home_editorial_image.jpg' | static_url | settings_image_url('huge') }} 640w, {{ 'home_editorial_image.jpg' | static_url | settings_image_url('original') }} 1024w"
						data-sizes="auto"
						alt="{{ settings.home_editorial_title | default(store.name) }}"
					>
				{% elseif params.preview %}
					<div class="home-editorial__image home-editorial__image--placeholder"></div>
				{% endif %}
			</div>

			{% if has_text_sticker %}
				<img
					class="home-editorial__sticker home-editorial__sticker--text"
					src="{{ 'home_editorial_text_sticker.jpg' | static_url | settings_image_url('large') }}"
					alt=""
					loading="lazy"
				>
			{% endif %}

			{% if has_editorial_text or params.preview %}
				<div class="home-editorial__text-card">
					{% if settings.home_editorial_subtitle %}
						<p class="home-editorial__subtitle">{{ settings.home_editorial_subtitle }}</p>
					{% endif %}
					{% if settings.home_editorial_title %}
						<h2 class="home-editorial__title">{{ settings.home_editorial_title }}</h2>
					{% endif %}
					{% if settings.home_editorial_text %}
						<p class="home-editorial__text">{{ settings.home_editorial_text }}</p>
					{% endif %}
					{% if settings.home_editorial_button and settings.home_editorial_button_url %}
						<a href="{{ settings.home_editorial_button_url | setting_url }}" class="btn btn-primary home-editorial__btn">{{ settings.home_editorial_button }}</a>
					{% endif %}
				</div>
			{% endif %}
		</div>

		{% if has_editorial_news or params.preview %}
			<div class="home-editorial__news-card">
				{% if has_news_sticker_left %}
					<img
						class="home-editorial__sticker home-editorial__sticker--news-left"
						src="{{ 'home_editorial_news_sticker_left.jpg' | static_url | settings_image_url('large') }}"
						alt=""
						loading="lazy"
					>
				{% endif %}
				{% if has_news_sticker_left_bottom %}
					<img
						class="home-editorial__sticker home-editorial__sticker--news-left-bottom"
						src="{{ 'home_editorial_news_sticker_left_bottom.jpg' | static_url | settings_image_url('large') }}"
						alt=""
						loading="lazy"
					>
				{% endif %}
				{% if has_news_sticker_right %}
					<img
						class="home-editorial__sticker home-editorial__sticker--news-right"
						src="{{ 'home_editorial_news_sticker_right.jpg' | static_url | settings_image_url('large') }}"
						alt=""
						loading="lazy"
					>
				{% endif %}
				<div class="home-editorial__news-content pr-md-5">
					
					<form method="post" action="/winnie-pooh" onsubmit="this.setAttribute('action', '');" data-store="home-editorial-newsletter-form" class="home-editorial__news-form">
						<div class="newsletter-form input-append">
							<div class="col p-0">
								<p class="home-editorial__news-text text-uppercase font-weight-bold">NEWSLETTER</p>
								{% if settings.home_editorial_news_title %}
									<div class="home-editorial__news-title h4">{{ settings.home_editorial_news_title }}</div>
								{% endif %}
								{% if settings.home_editorial_news_text %}
									<p class="home-editorial__news-text">{{ settings.home_editorial_news_text }}</p>
								{% endif %}
								<div class="home-editorial__news-fields">
									{% embed "snipplets/forms/form-input.tpl" with {
										type_text: true,
										input_name: 'name',
										input_id: 'home-editorial-name',
										input_placeholder: 'Tu nombre' | translate,
										input_aria_label: 'Tu nombre' | translate,
										input_group_custom_class: 'mb-0'
									} %}
									{% endembed %}
									{% embed "snipplets/forms/form-input.tpl" with {
										type_text: true,
										input_id: 'home-editorial-pet',
										input_placeholder: 'Nombre de tu mascota' | translate,
										input_aria_label: 'Nombre de tu mascota' | translate,
										input_group_custom_class: 'mb-0'
									} %}
									{% endembed %}
									{% embed "snipplets/forms/form-input.tpl" with {
										input_for: 'email',
										type_email: true,
										input_name: 'email',
										input_id: 'home-editorial-email',
										input_placeholder: 'Email' | translate,
										input_aria_label: 'Email' | translate,
										input_group_custom_class: 'mb-0'
									} %}
									{% endembed %}
								</div>
							</div>
							<div class="winnie-pooh" style="display: none;">
								<label for="winnie-pooh-editorial-newsletter">{{ "No completar este campo" | translate }}</label>
								<input id="winnie-pooh-editorial-newsletter" type="text" name="winnie-pooh"/>
							</div>
							<input type="hidden" id="home-editorial-news-message" name="message" value="{{ "Pedido de inscripción a newsletter" | translate }}" />
							<input type="hidden" name="type" value="newsletter" />
							<input type="submit" name="contact" class="btn newsletter-btn col-12 col-md-auto" value="{{ "Me sumo" | translate }}" />
							<svg class="icon-inline newsletter-btn"><use xlink:href="#arrow-long"/></svg>
						</div>
					</form>
					<script>
						(function() {
							var form = document.querySelector('[data-store="home-editorial-newsletter-form"]');
							if (!form) return;
							form.addEventListener('submit', function() {
								var pet = form.querySelector('#home-editorial-pet');
								var msg = form.querySelector('#home-editorial-news-message');
								if (!pet || !msg || !pet.value.trim()) return;
								msg.value = msg.value + ' — {{ "Nombre de tu mascota" | translate }}: ' + pet.value.trim();
							});
						})();
					</script>
					{% if contact and contact.type == 'newsletter' %}
						{% if contact.success %}
							<div class="alert alert-success mt-3 mb-0">{{ "¡Gracias por suscribirte! A partir de ahora vas a recibir nuestras novedades en tu email" | translate }}</div>
						{% else %}
							<div class="alert alert-danger mt-3 mb-0">{{ "Necesitamos tu email para enviarte nuestras novedades." | translate }}</div>
						{% endif %}
					{% endif %}
				</div>
			</div>
		{% endif %}
	</section>
{% endif %}
