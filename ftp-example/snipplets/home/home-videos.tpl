{% set quickshop_popup = settings.quick_shop and settings.quick_shop_type == 'popup' %}

{% if sections.videos.products %}
	<section class="section-home-videos home-videos" data-store="home-videos">
		{% if "home_videos_sticker.jpg" | has_custom_image %}
			<img
				class="home-videos__sticker"
				src="{{ 'home_videos_sticker.jpg' | static_url | settings_image_url('large') }}"
				alt=""
				loading="lazy"
			>
		{% endif %}
		{% if settings.home_videos_h1 or settings.home_videos_h2 %}
			<div class="container">
				<div class="row">
					<div class="col-12 text-center">
						<h2 class="home-videos__title pb-0 pb-md-4 h5 section-title">
							{% if settings.home_videos_h1 %}{{ settings.home_videos_h1 }}{% endif %}
							{% if settings.home_videos_h2 %} <em>{{ settings.home_videos_h2 }}</em>{% endif %}
						</h2>
					</div>
				</div>
			</div>
		{% endif %}
		<div class="home-videos__slider-outer">
			<div class="home-videos__slider-clip">
				<div class="swiper-container js-swiper-home-videos home-videos__slider">
					<div class="swiper-wrapper">
						{% for product in sections.videos.products %}
							{% set product_video_rendered = false %}
							{% for tag in product.tags %}
								{% if not product_video_rendered %}
									{% set tag_split = tag | split('leren:video:') %}
									{% if tag_split.1 %}
										{% set slide_video_url = tag_split.1 | trim %}
										{% set slide_video_provider = '' %}
										{% set slide_video_id = '' %}
										{% if slide_video_url %}
											{% if 'vimeo.com' in slide_video_url %}
												{% set slide_video_provider = 'vimeo' %}
												{% set slide_video_id = slide_video_url | split('?') | first | split('vimeo.com/') | last | split('/') | last %}
											{% elseif 'youtu.be/' in slide_video_url %}
												{% set slide_video_provider = 'youtube' %}
												{% set slide_video_id = slide_video_url | split('youtu.be/') | last | split('?') | first | split('&') | first %}
											{% elseif '/shorts/' in slide_video_url %}
												{% set slide_video_provider = 'youtube' %}
												{% set slide_video_id = slide_video_url | split('/shorts/') | last | split('?') | first %}
											{% elseif '/watch?v=' in slide_video_url %}
												{% set slide_video_provider = 'youtube' %}
												{% set slide_video_id = slide_video_url | split('/watch?v=') | last | split('&') | first %}
											{% elseif 'youtube.com/embed/' in slide_video_url %}
												{% set slide_video_provider = 'youtube' %}
												{% set slide_video_id = slide_video_url | split('/embed/') | last | split('?') | first %}
											{% endif %}
										{% endif %}
										{% if slide_video_provider and slide_video_id %}
											{% set product_video_rendered = true %}
											{% set product_url_with_selected_variant = product.url %}
											{% set state = store.is_catalog ? 'catalog' : (product.available ? product.display_price ? 'cart' : 'contact' : 'nostock') %}
											{% set texts = {'cart': "Agregar", 'contact': "Consultar precio", 'nostock': "Sin stock", 'catalog': "Consultar"} %}
											<div class="swiper-slide home-videos__slide">
											<div class="js-item-product js-item-slide" data-product-type="list" data-product-id="{{ product.id }}" data-store="product-item-{{ product.id }}" data-component="product-list-item" data-component-value="{{ product.id }}">
											<div class="js-product-container js-quickshop-container{% if product.variations %} js-quickshop-has-variants{% endif %}" data-variants="{{ product.variants_object | json_encode }}" data-quickshop-id="homevideo{{ product.id }}">
												<div class="home-videos__card">
													<div class="home-videos__media home-videos__media--video">
														<div class="home-videos__video-layer" aria-hidden="true">
															{% if slide_video_provider == 'youtube' %}
																<iframe
																	class="home-videos__iframe"
																	data-video-provider="youtube"
																	data-video-id="{{ slide_video_id }}"
																	src="https://www.youtube.com/embed/{{ slide_video_id }}?enablejsapi=1&mute=1&loop=1&controls=0&rel=0&modestbranding=1&playsinline=1&playlist={{ slide_video_id }}&disablekb=1&iv_load_policy=3&fs=0"
																	title="{{ product.name }}"
																	allow="autoplay; encrypted-media; picture-in-picture"
																	referrerpolicy="strict-origin-when-cross-origin"
																	tabindex="-1"
																></iframe>
															{% elseif slide_video_provider == 'vimeo' %}
																<iframe
																	class="home-videos__iframe"
																	data-video-provider="vimeo"
																	data-video-id="{{ slide_video_id }}"
																	src="https://player.vimeo.com/video/{{ slide_video_id }}?api=1&muted=1&loop=1&autoplay=0&controls=0&playsinline=1&title=0&byline=0&portrait=0&dnt=1"
																	title="{{ product.name }}"
																	allow="autoplay; fullscreen; picture-in-picture"
																	referrerpolicy="strict-origin-when-cross-origin"
																	tabindex="-1"
																></iframe>
															{% endif %}
														</div>
													</div>
												</div>
												{# Hidden form: the quickshop modal moves it into its body when it opens #}
												{% if quickshop_popup and product.variations and product.available and product.display_price and not product.isSubscribable() %}
													<div class="js-item-variants hidden">
														<form class="js-product-form" method="post" action="{{ store.cart_url }}">
															<input type="hidden" name="add_to_cart" value="{{ product.id }}" />
															{% include "snipplets/product/product-variants.tpl" with {quickshop: true} %}
															<input type="submit" class="js-addtocart js-prod-submit-form btn btn-primary w-100 mb-2 {{ state }}" value="{{ 'Agregar al carrito' | translate }}" />
															{% include 'snipplets/placeholders/button-placeholder.tpl' with {custom_class: "mb-2"} %}
														</form>
													</div>
												{% endif %}
												<div class="home-videos__product swiper-no-swiping">
													<a href="{{ product_url_with_selected_variant }}" class="home-videos__product-image" title="{{ product.name }}" aria-label="{{ product.name }}">
														{% if product.featured_image %}
															<img class="js-item-image" src="{{ product.featured_image | product_image_url('small') }}" srcset="{{ product.featured_image | product_image_url('small') }}" alt="{{ product.name }}" loading="lazy">
														{% endif %}
													</a>
													<div class="home-videos__product-info">
														<a href="{{ product_url_with_selected_variant }}" class="js-item-name home-videos__product-name" title="{{ product.name }}" data-store="product-item-name-{{ product.id }}">{{ product.name }}</a>
														{% if product.display_price %}
															<div class="home-videos__product-price js-item-price-container" data-store="product-item-price-{{ product.id }}">
																{% if product.compare_at_price %}
																	<span class="js-compare-price-display price-compare" style="display:inline-block;">{{ product.compare_at_price | money_nocents }}</span>
																{% endif %}
																<span class="js-price-display item-price" data-product-price="{{ product.price }}">{{ product.price | money_nocents }}</span>
															</div>
														{% endif %}
													</div>
													<div class="home-videos__product-actions js-item-quickshop">
														{% if product.available and product.display_price and not product.isSubscribable() %}
															{% if product.variations %}
																{% if quickshop_popup %}
																	<a data-toggle="#quickshop-modal" data-modal-url="modal-fullscreen-quickshop" href="#" class="js-quickshop-modal-open js-quickshop-slide js-modal-open js-fullscreen-modal-open btn btn-primary btn-small home-videos__product-btn" title="{{ 'Compra rápida de' | translate }} {{ product.name }}" aria-label="{{ 'Compra rápida de' | translate }} {{ product.name }}" data-component="product-list-item.add-to-cart" data-component-value="{{ product.id }}">{{ 'AGREGAR AL CARRITO' | translate }}</a>
																{% else %}
																	<a href="{{ product_url_with_selected_variant }}" class="btn btn-primary btn-small home-videos__product-btn" title="{{ product.name }}">{{ 'Ver producto' | translate }}</a>
																{% endif %}
															{% else %}
																<form class="js-product-form home-videos__product-form" method="post" action="{{ store.cart_url }}">
																	<input type="hidden" name="add_to_cart" value="{{ product.id }}" />
																	<input type="submit" class="js-addtocart js-prod-submit-form btn btn-primary btn-small home-videos__product-btn {{ state }}" value="{{ texts[state] | translate }}" {% if state == 'nostock' %}disabled{% endif %} data-component="product-list-item.add-to-cart" data-component-value="{{ product.id }}"/>
																	{% include 'snipplets/placeholders/button-placeholder.tpl' with {custom_class: 'btn-small home-videos__product-btn', direct_add: true} %}
																</form>
															{% endif %}
														{% elseif store.is_catalog or not product.display_price %}
															<a href="{{ product_url_with_selected_variant }}" class="btn btn-primary btn-small home-videos__product-btn">{{ texts[state] | translate }}</a>
														{% else %}
															<a href="{{ product_url_with_selected_variant }}" class="btn btn-primary btn-small home-videos__product-btn">{{ 'Ver producto' | translate }}</a>
														{% endif %}
													</div>
												</div>
											</div>{# js-quickshop-container #}
											</div>{# js-item-product #}
											</div>
										{% endif %}
									{% endif %}
								{% endif %}
							{% endfor %}
						{% endfor %}
					</div>
				</div>
			</div>
			<div class="js-swiper-home-videos-prev home-videos__nav home-videos__nav--prev swiper-button-prev swiper-nav-circle swiper-nav-circle--invert" aria-label="{{ 'Anterior' | translate }}">
				<svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long-neg"/></svg>
			</div>
			<div class="js-swiper-home-videos-next home-videos__nav home-videos__nav--next swiper-button-next swiper-nav-circle swiper-nav-circle--invert" aria-label="{{ 'Siguiente' | translate }}">
				<svg class="icon-inline icon-lg"><use xlink:href="#arrow-long-neg"/></svg>
			</div>
		</div>
		<div class="home-videos__dots js-home-videos-dots" aria-hidden="true"></div>
	</section>
{% endif %}
