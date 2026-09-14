{# Brands that work as examples #}

<div class="js-section-brands js-brands-placeholder home-brands-bar position-relative">
	<div class="container">
		<h2 class="js-brands-title h5 section-title mb-0 text-center home-brands-bar__title">{{ 'Nuestras marcas' | translate }}</h2>
	</div>
	<div class="home-brands-bar__track position-relative">
		<div class="js-swiper-empty-brands brand-swiper swiper-container">
			<div class="swiper-wrapper">
				{% for i in 1..10 %}
					<div class="swiper-slide home-brands-bar__slide">
						<div class="home-brands-bar__item">
							{{ component('placeholders/brand-placeholder' , {
								placeholder_classes: {
									svg_class: 'brand-image home-brands-bar__image svg-icon-text',
								}})
							}}
							<span class="home-brands-bar__name">{{ 'Marca' | translate }} {{ i }}</span>
						</div>
					</div>
				{% endfor %}
			</div>
		</div>
		<div class="js-swiper-empty-brands-prev home-brands-bar__nav home-brands-bar__nav--prev swiper-button-prev d-none d-md-flex svg-icon-text">
			<svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#chevron"/></svg>
		</div>
		<div class="js-swiper-empty-brands-next home-brands-bar__nav home-brands-bar__nav--next swiper-button-next d-none d-md-flex svg-icon-text">
			<svg class="icon-inline icon-lg"><use xlink:href="#chevron"/></svg>
		</div>
	</div>
	{% if not params.preview %}
		<div class="placeholder-overlay transition-soft">
			<div class="placeholder-info">
				<svg class="icon-inline icon-3x"><use xlink:href="#edit"/></svg>
				<div class="placeholder-description font-small-xs my-2">
					{{ "Podés subir logos desde" | translate }} <strong>"{{ "Marcas" | translate }}"</strong>
				</div>
				<a href="{{ admin_link }}#instatheme=pagina-de-inicio" class="btn-secondary btn btn-small placeholder-button">{{ "Editar" | translate }}</a>
			</div>
		</div>
	{% endif %}
</div>

{# Skeleton of "true" section accessed from instatheme.js #}
<div class="js-brands-top" style="display:none">
	{% include 'snipplets/home/home-brands.tpl' %}
</div>
