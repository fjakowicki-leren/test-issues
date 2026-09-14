{# Testimonials that work as example #}

<div class="js-section-testimonials js-testimonials-placeholder position-relative pb-5">
	<div class="container">
		<div class="row">
			<div class="col-12 text-center">
				<h2 class="js-testimonial-title h5 section-title mb-0">{{ 'Testimonios' | translate }}</h2>
			</div>
			<div class="js-testimonial-container col-12">
				<div class="js-swiper-testimonials-demo swiper-testimonials swiper-container text-center">
					<div class="swiper-wrapper">
						{% for i in 1..3 %}
							<div class="swiper-slide slide-container">
								<div class="testimonials-image testimonials-image-placeholder mb-3">
									<svg class="icon-inline icon-3x"><use xlink:href="#user"/></svg>
								</div>
								<p class="mb-3 px-5">{{ 'Descripción del testimonio' | translate }}</p>
								<div class="subtitle">{{ 'Testimonio' | translate }}</div>
							</div>
						{% endfor %}
					</div>
					<div class="js-swiper-testimonials-demo-pagination swiper-pagination swiper-pagination-bullets position-relative d-block d-md-none mt-5"></div>
				</div>
			</div>
		</div>
	</div>
	{% if not params.preview %}
		<div class="placeholder-overlay transition-soft">
			<div class="placeholder-info">
				<svg class="icon-inline icon-3x"><use xlink:href="#edit"/></svg>
				<div class="placeholder-description">
					{{ "Podés mostrar testimonios de tus clientes desde" | translate }} <strong>"{{ "Testimonios" | translate }}"</strong>
				</div>
				<a href="{{ admin_link }}#instatheme=pagina-de-inicio" class="btn-primary btn btn-small placeholder-button">{{ "Editar" | translate }}</a>
			</div>
		</div>
	{% endif %}
</div>

{# Skeleton of "true" section accessed from instatheme.js #}
<div class="js-testimonials-top" style="display:none">    
	{% include 'snipplets/home/home-testimonials.tpl' %}
</div>