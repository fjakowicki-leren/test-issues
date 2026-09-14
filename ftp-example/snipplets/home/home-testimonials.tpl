{% set has_home_testimonials = false %}
{% set num_testimonials = 0 %}
{% for testimonial in ['testimonial_01', 'testimonial_02', 'testimonial_03'] %}
	{% set testimonial_image = "#{testimonial}.jpg" | has_custom_image %}
	{% set testimonial_name = attribute(settings,"#{testimonial}_name") %}
	{% set testimonial_description = attribute(settings,"#{testimonial}_description") %}
	{% set has_testimonial = testimonial_name or testimonial_description or testimonial_image %}
	{% if has_testimonial %}
		{% set has_home_testimonials = true %}
		{% set num_testimonials = num_testimonials + 1 %}
	{% endif %}
{% endfor %}

{% if has_home_testimonials or params.preview %}
	<div class="js-section-testimonials pb-5{% if not settings.testimonials_title %} pt-5{% endif %}">
		<div class="container">
			<div class="row">
				<div class="js-testimonial-title-container col-12 text-center" {% if not settings.testimonials_title %}style="display: none"{% endif %}>
					<h2 class="js-testimonial-title h5 section-title mb-0">{{ settings.testimonials_title }}</h2>
				</div>
				<div class="js-testimonial-container col-12">
					<div class="js-swiper-testimonials swiper-testimonials swiper-container text-center">
						<div class="swiper-wrapper">
							{% for testimonial in ['testimonial_01', 'testimonial_02', 'testimonial_03'] %}
								{% set testimonial_image = "#{testimonial}.jpg" | has_custom_image %}
								{% set testimonial_name = attribute(settings,"#{testimonial}_name") %}
								{% set testimonial_description = attribute(settings,"#{testimonial}_description") %}
								{% set has_testimonial = testimonial_name or testimonial_description or testimonial_image %}
								<div class="js-testimonial-slide swiper-slide slide-container" {% if not has_testimonial %}style="display: none;"{% endif %}>
									<div class="js-testimonial-img-container testimonials-image mb-3" {% if not testimonial_image %}style="display: none"{% endif %}>
										<img class="js-testimonial-img js-testimonial-img-{{ loop.index }} lazyload" {% if testimonial_image %}src="{{ 'images/empty-placeholder.png' | static_url }}" data-src='{{ "#{testimonial}.jpg" | static_url | settings_image_url("small") }}'{% endif %} {% if testimonial_name %}alt="{{ testimonial_name }}"{% else %}alt="{{ 'Testimonio de' | translate }} {{ store.name }}"{% endif %} />
										<div class="placeholder-fade"></div>
									</div>
									<p class="js-testimonial-description js-testimonial-description-{{ loop.index }} mb-3 px-5" {% if not testimonial_description %}style="display: none"{% endif %}>{{ testimonial_description }}</p>
									<div class="js-testimonial-name js-testimonial-name-{{ loop.index }} subtitle" {% if not testimonial_name %}style="display: none"{% endif %}>{{ testimonial_name }}</div>
								</div>
							{% endfor %}
						</div>
						<div class="js-swiper-testimonials-pagination swiper-pagination swiper-pagination-bullets position-relative{% if num_testimonials > 1 %} d-block{% endif %} d-md-none mt-5"></div>
					</div>
				</div>
			</div>
		</div>
	</div>
{% endif %}
