{% set has_main_slider = settings.slider and settings.slider is not empty %}
{% set has_mobile_slider = settings.toggle_slider_mobile and settings.slider_mobile and settings.slider_mobile is not empty %}

{% if not mobile %}
<div class="js-home-main-slider-container home-slider-container {% if not has_main_slider and not params.preview %}hidden{% endif %}" data-transition="fade-in-up">
{% endif %}
	<div class="{% if mobile %}js-home-mobile-slider{% else %}js-home-main-slider{% endif %}-visibility {% if has_main_slider and has_mobile_slider %}{% if mobile %}d-md-none{% else %}d-none d-md-block{% endif %}{% elseif not settings.toggle_slider_mobile and mobile %}hidden{% endif %}">
		<div class="container-fluid">
			<div class="row">
				<div class="col section-slider p-0">
					<div class="js-home-slider{% if mobile %}-mobile{% endif %} nube-slider-home swiper-container swiper-container-horizontal swiper-text-align-{{ settings.slider_text_align | default('center') }}">
						<div class="swiper-wrapper">
							{% if mobile %}
								{% set slider = settings.slider_mobile %}
							{% else %}
								{% set slider = settings.slider %}
							{% endif %}
							{% for slide in slider %}
								<div class="swiper-slide slide-container">
									{% if slide.link %}
										<a href="{{ slide.link | setting_url }}" aria-label="{{ 'Carrusel' | translate }} {{ loop.index }}">
									{% endif %}	
									{% set has_text =  slide.title or slide.description or slide.button %}
									<div class="slider-slide">

										{% set apply_lazy_load = 
											settings.home_order_position_1 != 'slider' 
											or not (
												loop.first and (
													(has_main_slider and not has_mobile_slider) or 
													(has_mobile_slider and mobile)
												)
											) 
										%}

										{% if apply_lazy_load %}
											{% set slide_src = 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==' %}
										{% else %}
											{% set slide_src = slide.image | static_url | settings_image_url('large') %}
										{% endif %}

										<img 
											{% if not apply_lazy_load %}fetchpriority="high"{% endif %}
											{% if slide.width and slide.height %} width="{{ slide.width }}" height="{{ slide.height }}" {% endif %}
											{% if apply_lazy_load %}data-{% endif %}src="{{ slide_src }}"
											{% if apply_lazy_load %}data-{% endif %}srcset="{{ slide.image | static_url | settings_image_url('large') }} 480w, {{ slide.image | static_url | settings_image_url('huge') }} 640w, {{ slide.image | static_url | settings_image_url('original') }} 1024w, {{ slide.image | static_url | settings_image_url('1080p') }} 1920w"  
											class="slider-image {% if settings.slider_animation %}slider-image-animation{% endif %} {% if apply_lazy_load %}swiper-lazy fade-in{% endif %}" alt="{{ 'Carrusel' | translate }} {{ loop.index }}"
										/>
										<div class="placeholder-fade"></div>

										{% if has_text %}
											<div class="swiper-text swiper-{{ slide.color }}">	
												{% if slide.title %}
													<div class="h1 mb-3">{{ slide.title }}</div>
												{% endif %}
												{% if slide.description %}
													<p class="mb-3 swiper-text-description">{{ slide.description }}</p>
												{% endif %}
												{% if slide.button and slide.link %}
													<div class="btn swiper-text-btn">{{ slide.button }}</div>
												{% endif %}
											</div>
										{% endif %}
									</div>
									{% if slide.link %}
										</a>
									{% endif %}
								</div>
							{% endfor %}
						</div>
						<div class="js-swiper-home-control js-swiper-home-pagination{% if mobile %}-mobile{% endif %} swiper-pagination swiper-pagination-bullets d-block">
							{% if slider | length > 1 and not params.preview %}
								{% for slide in slider %}
									<span class="swiper-pagination-bullet"></span>
								{% endfor %}
							{% endif %}
						</div>
						<div class="js-swiper-home-control js-swiper-home-prev{% if mobile %}-mobile{% endif %} swiper-button-prev d-none d-md-block svg-square svg-icon-text">
							<svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#chevron"/></svg>
						</div>
						<div class="js-swiper-home-control js-swiper-home-next{% if mobile %}-mobile{% endif %} swiper-button-next d-none d-md-block svg-square svg-icon-text">
							<svg class="icon-inline icon-lg"><use xlink:href="#chevron"/></svg>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
{% if not mobile %}
</div>
{% endif %}