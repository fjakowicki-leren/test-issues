window.tiendaNubeInstaTheme = (function(jQueryNuvem) {
	return {
		waitFor: function() {
			return [];
		},
		placeholders: function() {
			return [
				{
					placeholder: '.js-home-slider-placeholder',
					content: '.js-home-slider-top',
					contentReady: function() {
						return $(this).find('img').length > 0;
					},
				},
				{
					placeholder: '.js-category-banner-placeholder',
					content: '.js-category-banner-top',
					contentReady: function() {
						return $(this).find('img').length > 0;
					},
				},
				{
					placeholder: '.js-promotional-banner-placeholder',
					content: '.js-promotional-banner-top',
					contentReady: function() {
						return $(this).find('img').length > 0;
					},
				},
				{
					placeholder: '.js-news-banner-placeholder',
					content: '.js-news-banner-top',
					contentReady: function() {
						return $(this).find('img').length > 0;
					},
				},
				{
					placeholder: '.js-module-banner-placeholder',
					content: '.js-module-banner-top',
					contentReady: function() {
						return $(this).find('img').length > 0;
					},
				},
				{
					placeholder: '.js-home-video-placeholder',
					content: '.js-home-video-top',
					contentReady: function() {
						// Show only if the thumbnail is ready
						return $(this).find('.js-home-video-container').attr('data-thumbnail-ready');
					},
				},
				{
					placeholder: '.js-testimonials-placeholder',
					content: '.js-testimonials-top',
					contentReady: function() {
						// Show only if there are any titles or image defined
						return 	$(this).find('.js-testimonial-container').text().trim() ||
								$(this).find('.js-testimonial-img').map(function(){
									return $(this).attr("src");
								}).get().join('').trim();
						},
				},
				{
					placeholder: '.js-brands-placeholder',
					content: '.js-brands-top',
					contentReady: function() {
						return $(this).find('img').length > 0;
					},
				},
			];
		},
		handlers: function(instaElements) {
			const handlers = {
				logo: new instaElements.Logo({
					$storeName: jQueryNuvem('#no-logo'),
					$logo: jQueryNuvem('#logo')
				}),
				// ----- Section order -----
				home_order_position: new instaElements.Sections({
					container: '.js-home-sections-container',
					data_store: {
						'slider': 'home-slider',
						'main_categories': 'home-categories-featured',
						'products': 'home-products-featured',
						'informatives': 'banner-services',
						'categories': 'home-banner-categories',
						'promotional': 'home-banner-promotional',
						'news_banners': 'home-banner-news',
						'new': 'home-products-new',
						'video': 'home-video',
						'sale': 'home-products-sale',
						'instafeed': 'home-instagram-feed',
						'welcome': 'home-welcome-message',
						'institutional': 'home-institutional-message',
						'testimonials': 'home-testimonials',
						'brands': 'home-brands',
						'main_product': 'home-product-main',
						'newsletter' : 'home-newsletter',
						'modules': 'home-image-text-module',
					}
				}),
			};

			// ----------------------------------- Slider -----------------------------------

			// Build the html for a slide given the data from the settings editor
			function buildHomeSlideDom(aSlide) {
				return '<div class="swiper-slide slide-container">' +
							(aSlide.link ? '<a href="' + aSlide.link + '">' : '' ) +
								'<img src="' + aSlide.src + '" class="slider-image"/>' +
								'<div class="swiper-text swiper-' + aSlide.color + '">' +
									(aSlide.title ? '<div class="h1 mb-3">' + aSlide.title + '</div>' : '' ) +
									(aSlide.description ? '<p class="mb-3">' + aSlide.description + '</p>' : '' ) +
									(aSlide.button && aSlide.link ? '<div class="btn btn-secondary btn-small">' + aSlide.button + '</div>' : '' ) +
								'</div>' +
							(aSlide.link ? '</a>' : '' ) +
						'</div>'
			}

			// Update main slider
			handlers.slider = new instaElements.Lambda(function(slides){
				if (!window.homeSwiper) {
					return;
				}

				window.homeSwiper.removeAllSlides();
				slides.forEach(function(aSlide){
					window.homeSwiper.appendSlide(buildHomeSlideDom(aSlide));
				});
			});

			// Update mobile slider
			handlers.slider_mobile = new instaElements.Lambda(function(slides){
				// This slider is not included in the html if `toggle_slider_mobile` is not set.
				// The second condition could be removed if live preview for this checkbox is implemented but changing the viewport size forces a refresh, so it's not really necessary.
				if (!window.homeMobileSwiper || !window.homeMobileSwiper.slides) {
					return;
				}

				window.homeMobileSwiper.removeAllSlides();
				slides.forEach(function(aSlide){
					window.homeMobileSwiper.appendSlide(buildHomeSlideDom(aSlide));
				});
			});

			// Update slider animation
			handlers.slider_animation = new instaElements.Lambda(function(sliderAnimation){
				const $swiperImage = $('.js-home-slider, .js-home-slider-mobile').find('.slider-image');
				if (sliderAnimation) {
					$swiperImage.addClass('slider-image-animation');
				} else {
					$swiperImage.removeClass('slider-image-animation');
				}
			});

			// ----------------------------------- Main Banners -----------------------------------

			// Build the html for a slide given the data from the settings editor

			var slideCount = 0;

			function buildHomeBannerDom(aSlide, bannerClasses, columnClasses, textClasses, imageContainerClasses, imageClasses, bannerModule) {
				slideCount++;
				var evenClass = slideCount % 2 === 0 ? 'js-banner-even order-md-first ' : '';
				return '<div class="js-live-preview-banner ' + bannerClasses + (bannerModule ? ' col-12 ' : ' ') + columnClasses + '">' +
						'<div class="js-textbanner textbanner ' + (bannerModule ? 'mb-md-5 pb-md-3' : '') + '">' +
							(aSlide.link ? '<a href="' + aSlide.link + '">' : '' ) +
								(bannerModule ? '<div class="row no-gutters align-items-center">' : '' ) +
									'<div class="textbanner-image ' + (bannerModule ? 'col-md-6 ' : '') + imageContainerClasses + '">' +
										'<img src="' + aSlide.src + '" class="textbanner-image-effect ' + imageClasses + '">' +
									'</div>' +
									(aSlide.title || aSlide.description || aSlide.button ? '<div class="js-textbanner-text textbanner-text ' + (bannerModule ? 'textbanner-module col-md-6 px-3 text-center ' + evenClass : '') + textClasses + '">' : '') +
										(aSlide.title ? '<div class="' + (bannerModule ? 'h1 mb-3' : 'js-banner-title h5 mb-0') + '">' + aSlide.title + '</div>' : '' ) +
										(aSlide.description ? '<div class="' + (bannerModule ? 'mb-3' : 'textbanner-paragraph') + '">' + aSlide.description + '</div>' : '' ) +
										(aSlide.button && aSlide.link ? '<div class="btn btn-secondary btn-small mt-2">' + aSlide.button + '</div>' : '' ) +
									(aSlide.title || aSlide.description || aSlide.button ? '</div>' : '') +
								(bannerModule ? '</div>' : '' ) +
							(aSlide.link ? '</a>' : '' ) +
						'</div>' +
					'</div>'
			}

			// Build swiper JS for Banners

			function initSwiperJS(bannerMainContainer, swiperId, swiperName, isModule){

				const swiperDesktopColumns = isModule ? 1 : bannerMainContainer.attr('data-desktop-columns');
				const swiperMobileColumns = (bannerMainContainer.attr('data-mobile-columns') == 2)
					? (bannerMainContainer.hasClass('js-home-banner') ? 2 : 2.25)
					: 1.15;

				createSwiper(`.js-swiper-${swiperId}`, {
					watchOverflow: true,
					centerInsufficientSlides: true,
					threshold: 5,
					watchSlideProgress: true,
					watchSlidesVisibility: true,
					slideVisibleClass: 'js-swiper-slide-visible',
					spaceBetween: 15,
					navigation: {
						nextEl: `.js-swiper-${swiperId}-next`,
						prevEl: `.js-swiper-${swiperId}-prev`
					},
					slidesPerView: swiperMobileColumns,
					breakpoints: {
						768: {
							slidesPerView: swiperDesktopColumns,
						}
					}
				},
				function(swiperInstance) {
					window[swiperName] = swiperInstance;
				});
			}

			// Main banners: Banner content and order updates. General layout and format updates (for main and secondary banners)

			['banner', 'banner_promotional', 'banner_news', 'module'].forEach(setting => {

				const bannerName = setting.replace('_', '-');
				const bannerPluralName = 
					setting == 'banner' ? 'banners' : 
					setting == 'banner_promotional' ? 'banners-promotional' : 
					setting == 'banner_news' ? 'banners-news' : 
					setting == 'module' ? 'modules' :
					null;

				const isModule = setting == 'module';
				const $generalBannersContainer = $(`.js-home-${bannerName}`);

				// Main banner
				const $mainBannersContainer = $generalBannersContainer.find(`.js-${bannerPluralName}`);

				// Mobile banner
				const bannerMobileName = 
					setting == 'banner' ? 'banners-mobile' : 
					setting == 'banner_promotional' ? 'banners-promotional-mobile' : 
					setting == 'banner_news' ? 'banners-news-mobile' :
					null;
				const $mobileBannersContainer = $generalBannersContainer.find(`.js-${bannerMobileName}`);
				
				const bannerSwiper = 
					setting == 'banner' ? 'homeBannerSwiper' :
					setting == 'banner_promotional' ? 'homeBannerPromotionalSwiper' : 
					setting == 'banner_news' ? 'homeBannerNewsSwiper' :
					setting == 'module' ? 'homeModuleSwiper' :
					null;

				// Used for specific mobile images swiper updates
				const bannerSwiperMobile = 
					setting == 'banner' ? 'homeBannerMobileSwiper' : 
					setting == 'banner_promotional' ? 'homeBannerPromotionalMobileSwiper' : 
					setting == 'banner_news' ? 'homeBannerNewsMobileSwiper' :
					null;

				const bannerModuleSetting = setting == 'module' ? true : false;
				const bannerFormat = $generalBannersContainer.attr('data-format');

				const desktopColumns = $generalBannersContainer.data('desktop-columns');
				const mobileColumns = $generalBannersContainer.data('mobile-columns');

				// Update banners content and order

				handlers[`${setting}`] = new instaElements.Lambda(function(slides){

					// Update text classes
					const textPosition = $generalBannersContainer.attr('data-text');
					const textClasses = textPosition == 'above' ? 'over-image' : 'background-main';

					// Update image classes
					const imageSize = $generalBannersContainer.attr('data-image');
					const imageClasses = imageSize == 'same' ? 'textbanner-image-background' : 'img-fluid d-block w-100';
					const imageContainerClasses = 
						imageSize == 'original' ? 'p-0' : 
						isModule && imageSize == 'same' ? 'textbanner-image-md' : '';

					const bannerFormat = $generalBannersContainer.attr('data-format');

					if (bannerFormat == 'slider') {

						// Update banner classes
						const bannerClasses = 'swiper-slide slide-container';
						// Avoids columnsClasses on slider
						const columnClasses = '';
						
						if (!window[bannerSwiper]) {
							return;
						}

						// Try using already created swiper JS, if it fails initialize swipers again
						try{
							window[bannerSwiper].removeAllSlides();
							slides.forEach(function(aSlide){
								window[bannerSwiper].appendSlide(buildHomeBannerDom(aSlide, bannerClasses, columnClasses, textClasses, imageContainerClasses, imageClasses, bannerModuleSetting));
							});	
						}catch(e){
							initSwiperJS($generalBannersContainer, bannerPluralName, bannerSwiper, isModule);

							setTimeout(function(){
								slides.forEach(function(aSlide){
									window[bannerSwiper].appendSlide(buildHomeBannerDom(aSlide, bannerClasses, columnClasses, textClasses, imageContainerClasses, imageClasses, bannerModuleSetting));
								});	
							},500);
						}

					} else {
						// Update banner classes
						const bannerClasses = isModule ? '' : 'grid-item';
						// Update column classes
						const desktopColumnsClasses = $generalBannersContainer.attr('data-grid-classes');
						const mobileColumns = $generalBannersContainer.attr('data-mobile-columns');
						const mobileColumnsClasses = mobileColumns == '2' ? 'col-6' : '';
						const columnClasses = desktopColumnsClasses + ' ' + mobileColumnsClasses;
						$mainBannersContainer.find('.swiper-slide-duplicate').remove();
						$mainBannersContainer.find(`.js-swiper-${bannerPluralName}-prev`).remove();
						$mainBannersContainer.find(`.js-swiper-${bannerPluralName}-next`).remove();
						$mainBannersContainer.find('.js-live-preview-banner').remove();

						slides.forEach(function(aSlide){
							$mainBannersContainer.find('.js-banner-row').append(buildHomeBannerDom(aSlide, bannerClasses, columnClasses, textClasses, imageContainerClasses, imageClasses, bannerModuleSetting));
						});
					}

					$generalBannersContainer.data('format', bannerFormat);
				});

				function initSwiperElements(bannerRow, bannerCol, swiperId, swiperName, isModule) {

					const $bannerItem = $generalBannersContainer.find('.js-live-preview-banner');

					$bannerItem.removeClass('grid-item col-6 col-12 col-md-3 col-md-4 col-md-5ths col-md-6 col-md-12');

					// Row to swiper wrapper
					bannerRow.removeClass('row').addClass('swiper-wrapper');

					// Wrap everything inside a swiper container
					bannerRow.wrapAll(`<div class="js-swiper-${swiperId} swiper-container"></div>`);

					// Replace each banner into a slide
					$bannerItem.addClass('swiper-slide slide-container p-0');

					// Add previous and next controls
					$generalBannersContainer.append(`
						<div class="js-swiper-${swiperId}-prev swiper-button-prev d-none d-md-block svg-square svg-icon-text ${isModule ? 'ml-3' : ''}">
							<svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#chevron"/></svg>
						</div>
						<div class="js-swiper-${swiperId}-next swiper-button-next d-none d-md-block svg-square svg-icon-text ${isModule ? 'mr-3' : ''}">
							<svg class="icon-inline icon-lg"><use xlink:href="#chevron"/></svg>
						</div>
					`);

					// Initialize swiper

					initSwiperJS($generalBannersContainer, swiperId, swiperName, isModule);
				}

				// Build grid markup and reset swiper

				function resetSwiperElements(bannersGroupContainer, bannerRow, swiperId, isModule) {

					// Update column classes
					const desktopColumnsClasses = $generalBannersContainer.attr('data-grid-classes');
					const mobileColumns = $generalBannersContainer.attr('data-mobile-columns');
					const mobileColumnsClasses = mobileColumns == '2' ? 'col-6' : '';
					const columnClasses = desktopColumnsClasses + ' ' + mobileColumnsClasses;

					// Update banner classes
					const bannerClasses = isModule ? '' : 'grid-item ' + columnClasses;

					const $bannerItem = $generalBannersContainer.find('.js-live-preview-banner');
					const $bannerText = $generalBannersContainer.find('.js-textbanner');
					const $bannerTextEven = $generalBannersContainer.find('.js-banner-even');

					if (isModule) {
						$bannerItem.addClass('col-12');
						$bannerText.addClass('mb-md-5 pb-md-3');
						$bannerTextEven.addClass('order-md-first');
					}

					// Remove duplicate slides and slider controls
					bannersGroupContainer.find('.swiper-slide-duplicate').remove();
					bannersGroupContainer.find(`.js-swiper-${swiperId}-prev`).remove();
					bannersGroupContainer.find(`.js-swiper-${swiperId}-next`).remove();

					// Swiper wrapper to row
					bannerRow.removeClass('swiper-wrapper').addClass('row').removeAttr('style');

					// Undo all slider wrappers and restore original classes
					bannerRow.unwrap();

					$bannerItem
						.removeClass('js-swiper-slide-visible swiper-slide-active swiper-slide-next swiper-slide-prev swiper-slide slide-container p-0')
						.addClass(bannerClasses)
						.removeAttr('style');	
				}

				// Toggle grid and slider format

				handlers[`${setting}_slider`] = new instaElements.Lambda(function(bannerSlider){

					// Main banners markup container
					const $mainBannerCol = $mainBannersContainer.find('.js-banner-col');
					const $mainBannerRow = $mainBannersContainer.find('.js-banner-row');
					const $mainBanner = $mainBannersContainer.find('.js-textbanner');
					const $mainBannerText = $mainBannersContainer.find('.js-textbanner-text');

					// Mobile banners markup container
					const $mobileBannerCol = $mobileBannersContainer.find('.js-banner-col');
					const $bannerMobileRow = $mobileBannersContainer.find('.js-banner-row');

					if (bannerSlider) {
						$generalBannersContainer.attr('data-format', 'slider');
						$mobileBannerCol.removeClass('pl-0').addClass('p-0');
						if (isModule) {
							$mainBanner.removeClass('mb-md-5 pb-md-3');
							$mainBannerText.removeClass('order-md-first');
						} else {
							$mainBannerCol.removeClass('pl-0').addClass('p-0');
						}
					} else {
						$generalBannersContainer.attr('data-format', 'grid');
						$mobileBannerCol.removeClass('p-0').addClass('pl-0');
						if (!isModule) {
							$mainBannerCol.removeClass('p-0').addClass('pl-0');
						}
					}

					const bannerFormat = $generalBannersContainer.attr('data-format');

					const toSlider = bannerFormat == "slider";

					if ($generalBannersContainer.data('format') == bannerFormat) {
						// Nothing to do
						return;
					}

					// From grid to slider
					if (toSlider) {
						initSwiperElements($mainBannerRow, $mainBannerCol, bannerPluralName, bannerSwiper, isModule);
						if (!isModule) {
							initSwiperElements($bannerMobileRow, $mobileBannerCol, bannerMobileName, bannerSwiperMobile);
						}
					
					// From slider to grid
					} else {
						resetSwiperElements($generalBannersContainer, $mainBannerRow, bannerPluralName, isModule);
						if (!isModule) {
							resetSwiperElements($generalBannersContainer, $bannerMobileRow, bannerMobileName);
						}

					}

					// Persist new format in data attribute
					$generalBannersContainer.data('format', bannerFormat);

				});
	
				// Update banner text position

				handlers[`${setting}_text_outside`] = new instaElements.Lambda(function(hasOutsideText){

					const $bannerText = $generalBannersContainer.find('.textbanner-text');

					if (hasOutsideText) {
						$generalBannersContainer.attr('data-text', 'outside');
						$bannerText.removeClass('over-image').addClass('background-main');
					} else {
						$generalBannersContainer.attr('data-text', 'above');
						$bannerText.removeClass('background-main').addClass('over-image');
					}
				});

				// Update banner size

				handlers[`${setting}_same_size`] = new instaElements.Lambda(function(bannerSize){

					const $bannerImageContainer = $generalBannersContainer.find('.js-live-preview-banner .textbanner-image');
					const $bannerImage = $generalBannersContainer.find('.js-live-preview-banner .textbanner-image-effect');

					if (bannerSize) {
						$generalBannersContainer.attr('data-image', 'same');
						$bannerImageContainer.removeClass('p-0');
						if (isModule) {
							$bannerImageContainer.addClass('textbanner-image-md');
						}
						$bannerImage.removeClass('img-fluid d-block w-100').addClass('textbanner-image-background');
					} else {
						$generalBannersContainer.attr('data-image', 'original');
						$bannerImageContainer.addClass('p-0');
						if (isModule) {
							$bannerImageContainer.removeClass('textbanner-image-md');
						}
						$bannerImage.removeClass('textbanner-image-background').addClass('img-fluid d-block w-100');
					}
				});

				if (!isModule) {

					// Update quantity desktop banners

					handlers[`${setting}_columns_desktop`] = new instaElements.Lambda(function(bannerQuantity){

						const $bannerItem = $generalBannersContainer.find('.js-live-preview-banner');
						const bannerFormat = $generalBannersContainer.attr('data-format');

						$bannerItem.removeClass('col-md-3 col-md-4 col-md-5ths col-md-6 col-md-12');
						if (bannerQuantity == 5) {
							$generalBannersContainer.attr('data-desktop-columns', bannerQuantity);
							$generalBannersContainer.attr('data-grid-classes', 'col-md-5ths');

							if (bannerFormat == 'grid') {
								$bannerItem.addClass('col-md-5ths');
							} else {
								if (window.innerWidth > 768) {
									window[bannerSwiper].params.slidesPerView = 5;
									window[bannerSwiperMobile].params.slidesPerView = 5;
								}
							}
						} else if (bannerQuantity == 4) {
							$generalBannersContainer.attr('data-desktop-columns', bannerQuantity);
							$generalBannersContainer.attr('data-grid-classes', 'col-md-3');

							if (bannerFormat == 'grid') {
								$bannerItem.addClass('col-md-3');
							} else {
								if (window.innerWidth > 768) {
									window[bannerSwiper].params.slidesPerView = 4;
									window[bannerSwiperMobile].params.slidesPerView = 4;
								}
							}
						} else if (bannerQuantity == 3) {
							$generalBannersContainer.attr('data-desktop-columns', bannerQuantity);
							$generalBannersContainer.attr('data-grid-classes', 'col-md-4');

							if (bannerFormat == 'grid') {
								$bannerItem.addClass('col-md-4');
							} else {
								if (window.innerWidth > 768) {
									window[bannerSwiper].params.slidesPerView = 3;
									window[bannerSwiperMobile].params.slidesPerView = 3;
								}
							}
						} else if (bannerQuantity == 2) {
							$generalBannersContainer.attr('data-desktop-columns', bannerQuantity);
							$generalBannersContainer.attr('data-grid-classes', 'col-md-6');

							if (bannerFormat == 'grid') {
								$bannerItem.addClass('col-md-6');
							} else {
								if (window.innerWidth > 768) {
									window[bannerSwiper].params.slidesPerView = 2;
									window[bannerSwiperMobile].params.slidesPerView = 2;
								}
							}
						} else if (bannerQuantity == 1) {
							$generalBannersContainer.attr('data-desktop-columns', bannerQuantity);
							$generalBannersContainer.attr('data-grid-classes', 'col-md-12');

							if (bannerFormat == 'grid') {
								$bannerItem.addClass('col-md-12');
							} else {
								if (window.innerWidth > 768) {
									window[bannerSwiper].params.slidesPerView = 1;
									window[bannerSwiperMobile].params.slidesPerView = 1;
								}
							}
						}
						if (bannerFormat == 'slider') {
							// Try using already created swiper JS, if it fails initialize swipers again
							try{
								window[bannerSwiper].update();
								window[bannerSwiperMobile].update();
							}catch(e){
								initSwiperJS($generalBannersContainer, bannerPluralName, bannerSwiper);
								initSwiperJS($generalBannersContainer, bannerMobileName, bannerSwiperMobile);
							}
						}
					});

					// Update quantity mobile banners

					handlers[`${setting}_columns_mobile`] = new instaElements.Lambda(function(bannerQuantity){

						const $bannerItem = $generalBannersContainer.find('.js-live-preview-banner');
						const bannerFormat = $generalBannersContainer.attr('data-format');

						$bannerItem.removeClass('col-6');
						if (bannerQuantity == 2) {
							$generalBannersContainer.attr('data-mobile-columns', bannerQuantity);
							if (bannerFormat == 'grid') {
								$bannerItem.addClass('col-6');
							} else {
								if (window.innerWidth < 768) {
									const mobileSlides = setting == 'banner' ? 2 : 2.25;
									window[bannerSwiper].params.slidesPerView = mobileSlides;
									window[bannerSwiperMobile].params.slidesPerView = mobileSlides;
								}
							}
						} else if (bannerQuantity == 1) {
							$generalBannersContainer.attr('data-mobile-columns', bannerQuantity);
							if (bannerFormat == 'slider') {
								if (window.innerWidth < 768) {
									window[bannerSwiper].params.slidesPerView = 1.15;
									window[bannerSwiperMobile].params.slidesPerView = 1.15;
								}
							}
						}

						if (bannerFormat == 'slider') {
							// Try using already created swiper JS, if it fails initialize swipers again
							try{
								window[bannerSwiper].update();
								window[bannerSwiperMobile].update();
							}catch(e){
								initSwiperJS($generalBannersContainer, bannerPluralName, bannerSwiper);
								initSwiperJS($generalBannersContainer, bannerMobileName, bannerSwiperMobile);
							}
						}
					});

					// Toggle mobile banners visibility

					handlers[`toggle_${setting}_mobile`] = new instaElements.Lambda(function(showMobileBanner){
						const bannerFormat = $generalBannersContainer.attr('data-format');

						$mainBannersContainer.removeClass("hidden d-md-none d-none d-md-block");
						$mobileBannersContainer.removeClass("hidden d-md-none d-none d-md-block");

						if (showMobileBanner) {
							// Each breakpoint shows on it's own device content
							$mainBannersContainer.addClass("d-none d-md-block");
							$mobileBannersContainer.addClass("d-md-none");
							$generalBannersContainer.attr('data-mobile-banners', '1');
							if (bannerFormat == 'slider') {
								// Try using already created swiper JS, if it fails initialize swipers again
								try{
									window[bannerSwiperMobile].update();
								}catch(e){
									initSwiperJS($generalBannersContainer, bannerMobileName, bannerSwiperMobile);
								}
							}
						} else {
							// Hide mobile banners
							$mobileBannersContainer.addClass("d-none");
							$generalBannersContainer.attr('data-mobile-banners', '0');
							if (bannerFormat == 'slider') {
								// Try using already created swiper JS, if it fails initialize swipers again
								try{
									window[bannerSwiper].update();
								}catch(e){
									initSwiperJS($generalBannersContainer, bannerPluralName, bannerSwiper);
								}
							}
						}
					});
				}
			});

			// Mobile banners: Banner content and order updates

			['banner_mobile', 'banner_promotional_mobile', 'banner_news_mobile'].forEach(setting => {

				const bannerName = setting.replace('_', '-').replace(/[-_]mobile$/, '');
				const bannerMobileName = 
					setting == 'banner_mobile' ? 'banners-mobile' : 
					setting == 'banner_promotional_mobile' ? 'banners-promotional-mobile' : 
					setting == 'banner_news_mobile' ? 'banners-news-mobile' :
					null;
				const $generalBannersContainer = $(`.js-home-${bannerName}`);

				// Target specific breakpoint to build correct slides on each device
				const $mobileBannersContainer = $generalBannersContainer.find(`.js-${bannerMobileName}`);

				const bannerSwiperMobile = 
					setting == 'banner_mobile' ? 'homeBannerMobileSwiper' : 
					setting == 'banner_promotional_mobile' ? 'homeBannerPromotionalMobileSwiper' : 
					setting == 'banner_news_mobile' ? 'homeBannerNewsMobileSwiper' :
					null;

				const desktopColumns = $generalBannersContainer.data('desktop-columns');
				const mobileColumns = $generalBannersContainer.data('mobile-columns');

				// Update banners content and order

				handlers[`${setting}`] = new instaElements.Lambda(function(slides){

					// Update text classes
					const textPosition = $generalBannersContainer.attr('data-text');
					const textClasses = textPosition == 'above' ? 'over-image' : 'background-main';

					// Update image classes
					const imageSize = $generalBannersContainer.attr('data-image');
					const imageClasses = imageSize == 'same' ? 'textbanner-image-background' : 'img-fluid d-block w-100';
					const imageContainerClasses = imageSize == 'original' ? 'p-0' : '';

					const bannerFormat = $generalBannersContainer.attr('data-format');
					const bannerModuleSetting = false;
					const isModule = false;
					
					if (bannerFormat == 'slider') {
						// Update banner classes
						const bannerClasses = 'swiper-slide slide-container';
						// Avoids columnsClasses on slider
						const columnClasses = '';

						if (!window[bannerSwiperMobile]) {
							return;
						}

						// Try using already created swiper JS, if it fails initialize swipers again
						try{

							window[bannerSwiperMobile].removeAllSlides();
							slides.forEach(function(aSlide){
								window[bannerSwiperMobile].appendSlide(buildHomeBannerDom(aSlide, bannerClasses, columnClasses, textClasses, imageContainerClasses, imageClasses, bannerModuleSetting));
							});

						}catch(e){
							initSwiperJS($generalBannersContainer, bannerMobileName, bannerSwiperMobile, isModule);

							setTimeout(function(){
								slides.forEach(function(aSlide){
									window[bannerSwiperMobile].appendSlide(buildHomeBannerDom(aSlide, bannerClasses, columnClasses, textClasses, imageContainerClasses, imageClasses, bannerModuleSetting));
								});	
							},500);
						}

					} else {
						// Update banner classes
						const bannerClasses = 'grid-item';
						// Update column classes
						const desktopColumnsClasses = $generalBannersContainer.attr('data-grid-classes');
						const mobileColumns = $generalBannersContainer.attr('data-mobile-columns');
						const mobileColumnsClasses = mobileColumns == '2' ? 'col-6' : '';
						const columnClasses = desktopColumnsClasses + ' ' + mobileColumnsClasses;
						$mobileBannersContainer.find('.swiper-slide-duplicate').remove()
						$mobileBannersContainer.find(`.js-swiper-${bannerMobileName}-prev`).remove()
						$mobileBannersContainer.find(`.js-swiper-${bannerMobileName}-next`).remove()
						$mobileBannersContainer.find('.js-live-preview-banner').remove();
						slides.forEach(function(aSlide){
							$mobileBannersContainer.find('.js-banner-row').append(buildHomeBannerDom(aSlide, bannerClasses, columnClasses, textClasses, imageContainerClasses, imageClasses));
						});
					}

					$generalBannersContainer.data('format', bannerFormat);
				});
			});

			// ----------------------------------- Welcome Message -----------------------------------

			// Update welcome message title
			handlers.welcome_message = new instaElements.Text({
				element: '.js-welcome-message-title',
				show: function(){
					$(this).show();
				},
				hide: function(){
					$(this).hide();
				},
			});

			// Update welcome message subtitle
			handlers.welcome_text = new instaElements.Text({
				element: '.js-welcome-message-text',
				show: function(){
					$(this).show();
					$('.js-welcome-message-title').removeClass('mb-0');
				},
				hide: function(){
					$(this).hide();
					$('.js-welcome-message-title').addClass('mb-0');
				},
			});

			// ----------------------------------- Institutional Message -----------------------------------

			// Update institutional message title
			handlers.institutional_message = new instaElements.Text({
				element: '.js-institutional-message-title',
				show: function(){
					$(this).show();
				},
				hide: function(){
					$(this).hide();
				},
			});

			// Update institutional message subtitle
			handlers.institutional_text = new instaElements.Text({
				element: '.js-institutional-message-text',
				show: function(){
					$(this).show();
				},
				hide: function(){
					$(this).hide();
				},
			});

			// ----------------------------------- Newsletter -----------------------------------

			// Updates title and text for newsletter form
			['title', 'text'].forEach(setting => {
				handlers[`home_news_${setting}`] = new instaElements.Text({
					element: `.js-home-newsletter-${setting}`,
					show: function(){
						$(this).show();
					},
					hide: function(){
						$(this).hide();
					},
				});
			});

			// Text align
			handlers.home_news_align = new instaElements.Lambda(function(alignText){
				
				const $container = $('.js-home-newsletter-form');

				if (alignText == 'center') {
					$container.addClass("text-center");
				} else {
					$container.removeClass("text-center");
				}
			});

			// Newsletter images visibility
			function newsletterImagesVisibility(){

				const $newsContainer = $(".js-home-newsletter-container"); 
				const $newsImagesContainer = $(".js-home-newsletter-image-container"); 
				const $newsImage = $newsImagesContainer.find('.js-home-newsletter-image');
				const $newsImageMobile = $newsImagesContainer.find('.js-home-newsletter-image-mobile');
				const hasImage = $newsImagesContainer.find('.js-home-newsletter-image').attr('src');
				const hasImageMobile = $newsImagesContainer.find('.js-home-newsletter-image-mobile').attr('src');
				const hasImages = $newsImage.attr('src') || $newsImageMobile.attr('src');

				if(hasImages){
					$newsImagesContainer.show();
					$newsContainer.addClass("section-newsletter-home-images");
				}else{
					$newsImagesContainer.hide();
					$newsContainer.removeClass("section-newsletter-home-images");
				}

				// Hides mobile image if has desktop image

				$newsImage.removeClass("d-block d-none d-md-block d-md-none");
				$newsImageMobile.removeClass("d-block d-none d-md-block d-md-none");

				if (hasImage) {
					$newsImageMobile.addClass('d-block d-md-none');
				} else {
					$newsImageMobile.removeClass('d-block d-md-none');
				}
				// Hides desktop image if has mobile image
				if (hasImageMobile) {
					$newsImage.addClass('d-none d-md-block');
				} else {
					$newsImage.removeClass('d-none d-md-block');
				}
			}

			newsletterImagesVisibility();

			// Updates newsletter images
			['image', 'image_mobile'].forEach(setting => {
				const imageName = setting.replace('_', '-');
				handlers[`home_news_${setting}.jpg`] = new instaElements.Image({
					element: `.js-home-newsletter-${imageName}`,
					show: function() {
						$(this).show();
						newsletterImagesVisibility();
					},
					hide: function() {
						$(this).hide();
						newsletterImagesVisibility();
					},
				});
			});

			// Newsletter colors
			handlers.home_news_colors = new instaElements.Lambda(function(newsColors){
				
				const $container = $('.js-home-newsletter-container');

				if (newsColors) {
					$container.addClass("section-newsletter-home-colors");
				} else {
					$container.removeClass("section-newsletter-home-colors");
				}
			});

			// ----------------------------------- Testimonials -----------------------------------

			// Update testimonials section title
			handlers.testimonials_title = new instaElements.Text({
				element: '.js-testimonial-title',
				show: function(){
					$(this).show();
				},
				hide: function(){
					$(this).hide();
				},
			});

			// Updates testimonials section title: Using Lambda instead of Text to target multiple titles (placeholder and final feature)
			handlers.testimonials_title = new instaElements.Lambda(function(testimonialsTitle){
				const $testimonialsTitle = $('.js-testimonial-title');
				const $testimonialsTitleContainer = $('.js-testimonial-title').parent();
				const $testimonialsContainer = $(".js-section-testimonials");

				$testimonialsTitle.text(testimonialsTitle);

				if(testimonialsTitle){
					$testimonialsTitleContainer.show();
					$testimonialsContainer.removeClass('pt-5');
				}else{
					$testimonialsTitleContainer.hide();
					$testimonialsContainer.addClass('pt-5');
				}
			});

			// Updates visibility of each testimonial

			function testimonialContentVisibility(container){
				const hasContent = $(container).find('.js-testimonial-description').text().trim() || 
						$(container).find('.js-testimonial-name').text().trim() ||
						$(container).find('.js-testimonial-img').attr('src');
				if(hasContent){
					$(container).show();
				}else{
					$(container).hide();
				}

				window.testimonialsSwiper.params.observer = true;
				window.testimonialsSwiper.update();
			}

			// Updates visibility of each testimonial's content

			for (let i = 1; i <= 4; i++) {
				// Update image for each testimonials banner
				handlers[`testimonial_0${i}.jpg`] = new instaElements.Image({
					element: `.js-testimonial-img-${i}`,
					show: function() {
						$(this).parent(".js-testimonial-img-container").show();

						// Maybe show container now that there's content inside
						testimonialContentVisibility($(this).closest('.js-section-testimonials, .js-testimonial-slide'));
					},
					hide: function() {
						$(this).parent().hide();

						// Maybe hide if there's no content inside
						testimonialContentVisibility($(this).closest('.js-section-testimonials, .js-testimonial-slide'));
					},
				});

				// Update title and description for each informative banner
				['name', 'description'].forEach(setting => {
					handlers[`testimonial_0${i}_${setting}`] = new instaElements.Text({
						element: `.js-testimonial-${setting}-${i}`,
						show: function(){
							$(this).show();
							testimonialContentVisibility($(this).closest('.js-testimonial-slide'));
						},
						hide: function(){
							$(this).hide();
							testimonialContentVisibility($(this).closest('.js-testimonial-slide'));
						},
					});
				});
			}

			// ----------------------------------- Brands Slider -----------------------------------

			// Build the html for a slide given the data from the settings editor
			function buildBrandsSlideDom(aSlide) {
				return '<div class="swiper-slide slide-container text-center">' +
					(aSlide.link ? '<a href="' + aSlide.link + '">' : '' ) +
					'<img src="' + aSlide.src + '" class="brand-image"/>' +
					(aSlide.link ? '</a>' : '' ) +
					'</div>'
			}

			// Updates brands section padding
			handlers.brands_title = new instaElements.Lambda(function(brandsTitle){
				const $brandsTitle = $('.js-brands-title');
				const $brandsTitleContainer = $('.js-brands-title').parent();
				const $brandsContainer = $(".js-section-brands");

				$brandsTitle.text(brandsTitle);

				if(brandsTitle){
					$brandsTitleContainer.show();
					$brandsContainer.removeClass('pt-5');
				}else{
					$brandsTitleContainer.hide();
					$brandsContainer.addClass('pt-5');
				}
			});

			// Update brands carousel
			handlers.brands = new instaElements.Lambda(function(slides){
				if (!window.brandsSwiper) {
					return;
				}

				window.brandsSwiper.removeAllSlides();
				slides.forEach(function(aSlide){
					window.brandsSwiper.appendSlide(buildBrandsSlideDom(aSlide));
				});
			});

			// ----------------------------------- Highlighted Products -----------------------------------

			// Same logic applies to all 3 types of highlighted products

			function updateProductsDesktopQuantity(quantity, format, item, swiper) {
				if (format == 'grid') {
					if (quantity == 4) {
						item.addClass('col-md-3');
					} else if (quantity == 3) {
						item.addClass('col-md-4');
					} else if (quantity == 2) {
						item.addClass('col-md-6');
					}
				}else{
					window[swiper].params.slidesPerView = quantity;
					window[swiper].update();
				}
			}

			function updateProductsMobileQuantity(quantity, sliderQuantity, format, item, swiper) {
				if (format == 'grid') {
					if (quantity == 1) {
						item.addClass('col-12');
					} else if (quantity == 2) {
						item.addClass('col-6');
					} else if (quantity == 3) {
						item.addClass('col-4');
					}
				}else{
					window[swiper].params.slidesPerView = sliderQuantity;
					window[swiper].update();
				}
			}

			['featured', 'sale', 'new'].forEach(setting => {
				const $productContainer = $(`.js-products-${setting}-container`);
				const $productCol = $(`.js-products-${setting}-col`);
				const $productGrid = $(`.js-products-${setting}-grid`);
				const $productItem = $productGrid.find(`.js-item-product`);

				const productSwiper = 
					setting == 'featured' ? 'productsFeaturedSwiper' : 
					setting == 'new' ? 'productsNewSwiper' : 
					setting == 'sale' ? 'productsSaleSwiper' :
					null;

				// Updates title text
				handlers[`${setting}_products_title`] = new instaElements.Text({
					element: `.js-products-${setting}-title`,
					show: function(){
						$(this).show();
					},
					hide: function(){
						$(this).hide();
					},
				})

				// Updates quantity products desktop
				handlers[`${setting}_products_desktop`] = new instaElements.Lambda(function(desktopProductQuantity){
					if (window.innerWidth > 768) {
						const productFormat = $productGrid.attr('data-format');
						const listGrid = $productGrid.attr('data-desktop-grid');
						$productItem.removeClass('col-md-3 col-md-4 col-md-6');

						if (desktopProductQuantity == 'default') {
							$productGrid.attr('data-desktop-grid', 'true');
							const desktopListQuantity = $productGrid.attr('data-desktop-grid-columns');
							$productGrid.attr('data-desktop-columns', desktopListQuantity);
							updateProductsDesktopQuantity(desktopListQuantity, productFormat, $productItem, productSwiper);
						}else{
							$productGrid.attr({
								'data-desktop-grid': 'false',
								'data-desktop-columns': desktopProductQuantity
							});
							updateProductsDesktopQuantity(desktopProductQuantity, productFormat, $productItem, productSwiper);
						}						
					}
				});

				// Updates quantity products mobile
				handlers[`${setting}_products_mobile`] = new instaElements.Lambda(function(mobileProductQuantity){

					// Update home quantities based on section settings
					const $productHomeItem = $productGrid.find('.js-item-product');
					const $productHomeItemName = $productHomeItem.find('.js-item-name');
					const $productHomeItemPriceContainer = $productHomeItem.find('.js-item-price-container');
					const $productHomeItemPriceCompare = $productGrid.find(".js-compare-price-display");
					const $productHomeItemColorsContainer = $productGrid.find('.js-item-colors-container');
					const $productHomeItemInstallmentsContainer = $productGrid.find('.js-item-installments-container');
					const $productHomeItemQuickshop = $productGrid.find('.js-item-quickshop');

					// Define mobile item elements visibility when mobile cols are narrow 
					function setItemMobileContentVisiblity() {
						const mobileProductGridQuantity = $productGrid.attr('data-mobile-grid-columns');
						const mobileProductListGrid = $productGrid.attr('data-mobile-grid');
						if (mobileProductQuantity == 3 || (mobileProductListGrid == 'true' && mobileProductGridQuantity == 3)) {
							$productHomeItemName.addClass("d-none d-md-block");
							$productHomeItemPriceContainer.removeClass("mb-2").addClass("mb-0 mb-md-2");
							$productHomeItemColorsContainer.addClass("d-none d-md-block");
							$productHomeItemInstallmentsContainer.addClass("d-none d-md-block");
							$productHomeItemQuickshop.addClass("d-none d-md-inline-block");
							$productHomeItem.find(".js-compare-price-display[data-price-compare-visibility='true']").addClass("d-none d-md-inline-block");
						}else{
							$productHomeItemName.removeClass("d-none d-md-block");
							$productHomeItemPriceContainer.removeClass("mb-0 mb-md-2").addClass("mb-2");
							$productHomeItemPriceCompare.removeClass("d-none d-md-inline-block");
							$productHomeItemColorsContainer.removeClass("d-none d-md-block");
							$productHomeItemInstallmentsContainer.removeClass("d-none d-md-block");
							$productHomeItemQuickshop.removeClass("d-none d-md-inline-block");
							$productHomeItem.find(".js-compare-price-display").removeClass("d-none d-md-inline-block");
						}
					}

					if (window.innerWidth < 768) {
						const productFormat = $productGrid.attr('data-format');
						const listGrid = $productGrid.attr('data-mobile-grid');
						const mobileListSliderQuantity = $productGrid.attr('data-mobile-grid-slider-columns');
						const mobileProductSliderQuantity = mobileProductQuantity == '3' ? '3.25' : mobileProductQuantity == '2' ? '2.25' : mobileProductQuantity == '1' ? '1.15' : mobileListSliderQuantity;
						$productItem.removeClass('col-6 col-12');

						if (mobileProductQuantity == 'default') {
							$productGrid.attr('data-mobile-grid', 'true');
							const mobileListQuantity = $productGrid.attr('data-mobile-grid-columns');
							$productGrid.attr('data-mobile-columns', mobileListQuantity);
							updateProductsMobileQuantity(mobileListQuantity, mobileListSliderQuantity, productFormat, $productItem, productSwiper);
						}else{
							$productGrid.attr({
								'data-mobile-grid': 'false',
								'data-mobile-columns': mobileProductQuantity,
								'data-mobile-slider-columns': mobileProductSliderQuantity
							});
							updateProductsMobileQuantity(mobileProductQuantity, mobileProductSliderQuantity, productFormat, $productItem, productSwiper);
						}

						setItemMobileContentVisiblity();
					}
				});

				// Initialize swiper function
				function initSwiperElements() {

					const desktopProductQuantity = $productGrid.attr('data-desktop-columns');
					const mobileProductQuantity = $productGrid.attr('data-mobile-columns');

					let desktopQuantity = $productGrid.attr('data-desktop-grid-columns');
					if (desktopProductQuantity != 'default') {
						desktopQuantity = $productGrid.attr('data-desktop-columns');
					}

					let mobileQuantity = $productGrid.attr('data-mobile-slider-columns');
					if (mobileProductQuantity != 'default') {
						mobileQuantity = $productGrid.attr('data-mobile-grid-slider-columns');
					}

					$productGrid.addClass('swiper-wrapper').removeClass("row");

					// Wrap everything inside a swiper container
					$productGrid.wrapAll(`<div class="js-swiper-${setting} swiper-container"></div>`)

					// Wrap each product into a slide
					$productItem.addClass("p-0").removeClass("col-3 col-4 col-6 col-12 col-md-3 col-md-4 col-md-6 ").wrap(`<div class="swiper-slide"></div>`);
					$productCol.addClass("p-0").removeClass("pl-0");

					// Add previous and next controls
					$productContainer.append(`
						<div class="js-swiper-${setting}-prev swiper-button-prev d-none d-md-block svg-square svg-icon-text">
							<svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#chevron"/></svg>
						</div>
						<div class="js-swiper-${setting}-next swiper-button-next d-none d-md-block svg-square svg-icon-text">
							<svg class="icon-inline icon-lg"><use xlink:href="#chevron"/></svg>
						</div>
					`);
					
					// Initialize swiper
					createSwiper(`.js-swiper-${setting}`, {
						lazy: true,
						watchOverflow: true,
						centerInsufficientSlides: true,
						threshold: 5,
						watchSlideProgress: true,
						watchSlidesVisibility: true,
						slideVisibleClass: 'js-swiper-slide-visible',
						spaceBetween: 15,
						loop: $productItem.length > 3,
						navigation: {
							nextEl: `.js-swiper-${setting}-next`,
							prevEl: `.js-swiper-${setting}-prev`
						},
						pagination: {
							el: `.js-swiper-${setting}-pagination`,
							type: 'fraction',
						},
						slidesPerView: mobileQuantity,
						breakpoints: {
							768: {
								slidesPerView: desktopQuantity,
							}
						},
					},
					function(swiperInstance) {
						window[productSwiper] = swiperInstance;
					});
				}

				// Reset swiper function
				function resetSwiperElements() {
					const desktopProductQuantity = $productGrid.attr('data-desktop-columns');
					const mobileProductQuantity = $productGrid.attr('data-mobile-columns');

					// Remove duplicate slides and slider controls
					$productContainer.find(`.js-swiper-${setting}-prev`).remove();
					$productContainer.find(`.js-swiper-${setting}-next`).remove();
					$productCol.addClass("pl-0").removeClass("p-0");
					$productGrid.find('.swiper-slide-duplicate').remove();
					$productGrid.addClass('row');

					// Undo all slider wrappers and restore original classes
					$productGrid.unwrap();
					$productItem.unwrap();
					$productItem.removeClass('js-item-slide swiper-slide p-0').removeAttr('style');

					let desktopQuantity = $productGrid.attr('data-desktop-grid-columns');
					if (desktopProductQuantity != 'default') {
						desktopQuantity = $productGrid.attr('data-desktop-columns');
					}

					if (desktopQuantity == 4) {
						$productItem.addClass('col-md-3');
					} else if (desktopQuantity == 3) {
						$productItem.addClass('col-md-4');

					} else if (desktopQuantity == 2) {
						$productItem.addClass('col-md-6');
					}

					let mobileQuantity = $productGrid.attr('data-mobile-grid-columns');
					if (mobileProductQuantity != 'default') {
						mobileQuantity = $productGrid.attr('data-mobile-columns');
					}

					if (mobileQuantity == 1) {
						$productItem.addClass('col-12');
					} else if (mobileQuantity == 2) {
						$productItem.addClass('col-6');
					} else if (mobileQuantity == 3) {
						$productItem.addClass('col-4');
					}
				}

				// Toggle grid and slider view
				handlers[`${setting}_products_format`] = new instaElements.Lambda(function(format){
					const toSlider = format == "slider";

					if ($productGrid.attr('data-format') == format) {
						// Nothing to do
						return;
					}

					// From grid to slider
					if (toSlider) {
						$productGrid.attr('data-format', 'slider');

						// Convert grid to slider if it's not yet
						if ($productContainer.find('.swiper-slide').length < 1) {
							initSwiperElements();
						}

					// From slider to grid
					} else {
						$productGrid.attr('data-format', 'grid');
						
						// Reset swiper settings
						resetSwiperElements();

						// Restore grid settings
						$productGrid.removeClass('swiper-wrapper').removeAttr('style');
					}

					// Persist new format in data attribute
					$productGrid.attr('data-format', format);
				});
			});

			// Update home quantities based on general list and each home produts format settings

			// Define home product grid
			const $productHomeGrid = $('.js-products-home-grid');

			// Updates quantity products desktop
			handlers.grid_columns_desktop = new instaElements.Lambda(function(desktopProductQuantity){
				if (window.innerWidth > 768) {
					
					$productHomeGrid.attr('data-desktop-grid-columns', desktopProductQuantity);
					$productHomeGrid.each(function() {
						const thisProductFormat = $(this).attr('data-format');
						const thisSectionId = $(this).attr('data-section-id');
						const thisListGrid = $(this).attr('data-desktop-grid');
						const productSwiper = 
							thisSectionId == 'featured' ? 'productsFeaturedSwiper' : 
							thisSectionId == 'new' ? 'productsNewSwiper' : 
							thisSectionId == 'sale' ? 'productsSaleSwiper' :
							null;

						const $thisProductHomeItem = $(this).find('.js-item-product');
						
						if (thisListGrid == 'true') {
							$thisProductHomeItem.removeClass('col-md-3 col-md-4 col-md-6');
							$productHomeGrid.attr('data-desktop-columns', desktopProductQuantity);
							updateProductsDesktopQuantity(desktopProductQuantity, thisProductFormat, $thisProductHomeItem, productSwiper);
						}
					});
				}
			});

			// Updates quantity products mobile
			handlers.grid_columns_mobile = new instaElements.Lambda(function(mobileProductQuantity){
				if (window.innerWidth < 768) {
					const mobileProductSliderQuantity = mobileProductQuantity == '3' ? '3.25' : mobileProductQuantity == '2' ? '2.25' : '1.15';
					$productHomeGrid.attr({
						'data-mobile-grid-slider-columns': mobileProductSliderQuantity,
						'data-mobile-grid-columns': mobileProductQuantity
					});

					$productHomeGrid.each(function() {
						const thisProductFormat = $(this).attr('data-format');
						const thisSectionId = $(this).attr('data-section-id');
						const thisListGrid = $(this).attr('data-mobile-grid');
						const productSwiper = 
							thisSectionId == 'featured' ? 'productsFeaturedSwiper' : 
							thisSectionId == 'new' ? 'productsNewSwiper' : 
							thisSectionId == 'sale' ? 'productsSaleSwiper' :
							null;

						const $thisProductHomeItem = $(this).find('.js-item-product');
						
						if (thisListGrid == 'true') {
							$thisProductHomeItem.removeClass('col-4 col-6 col-12');
							$productHomeGrid.attr('data-mobile-slider-columns', mobileProductSliderQuantity).attr('data-mobile-columns', mobileProductQuantity);
							updateProductsMobileQuantity(mobileProductQuantity, mobileProductSliderQuantity, thisProductFormat, $thisProductHomeItem, productSwiper);

							// Update home quantities based on general list settings
							const $productHomeItem = $(this).find('.js-item-product');
							const $productHomeItemName = $thisProductHomeItem.find('.js-item-name');
							const $productHomeItemPriceContainer = $thisProductHomeItem.find('.js-item-price-container');
							const $productHomeItemPriceCompare = $(this).find(".js-compare-price-display");
							const $productHomeItemColorsContainer = $(this).find('.js-item-colors-container');
							const $productHomeItemInstallmentsContainer = $(this).find('.js-item-installments-container');
							const $productHomeItemQuickshop = $(this).find('.js-item-quickshop');
							const mobileProductGridQuantity = $(this).attr('data-mobile-grid-columns');

							// Define mobile item elements visibility when mobile cols are narrow
							function setItemMobileContentVisiblity() {
								if (mobileProductGridQuantity == 3) {
									$productHomeItemName.addClass("d-none d-md-block");
									$productHomeItemPriceContainer.removeClass("mb-2").addClass("mb-0 mb-md-2");
									$productHomeItemColorsContainer.addClass("d-none d-md-block");
									$productHomeItemInstallmentsContainer.addClass("d-none d-md-block");
									$productHomeItemQuickshop.addClass("d-none d-md-inline-block");
									$productHomeItem.find(".js-compare-price-display[data-price-compare-visibility='true']").addClass("d-none d-md-inline-block");
								}else{
									$productHomeItemName.removeClass("d-none d-md-block");
									$productHomeItemPriceContainer.removeClass("mb-0 mb-md-2").addClass("mb-2");
									$productHomeItemPriceCompare.removeClass("d-none d-md-inline-block");
									$productHomeItemColorsContainer.removeClass("d-none d-md-block");
									$productHomeItemInstallmentsContainer.removeClass("d-none d-md-block");
									$productHomeItemQuickshop.removeClass("d-none d-md-inline-block");
									$productHomeItem.find(".js-compare-price-display").removeClass("d-none d-md-inline-block");
								}
							}
							setItemMobileContentVisiblity();
						}
					});
					
				}
			});

			// ----------------------------------- Video -----------------------------------

			function generateVideoThumb(videoId){
				// Generate default video thumb
				const defaultThumb = $(".js-home-video-image img");
				defaultThumb.hide();
				let defaultThumbSrc = 'https://img.youtube.com/vi_webp/' + videoId + '/maxresdefault.webp';
				defaultThumb.attr("src", defaultThumbSrc).show();
			}

			function generateVideo(videoId){
				const videoType = $('.js-home-video-container').attr("data-video-type");
				const allowCustomThumbVisibility = $('.js-home-video-container').attr("data-allow-custom-thumb");
				const customVideoThumb = $('.js-home-video-container').attr("data-custom-thumb");
				const customVideoThumbSrc = $(".js-home-video-image img").attr("src");

				// Reset existing iframe and create new one
				$(".js-home-video").remove();

				let newVideo = $('<div>', {
				    class: 'js-home-video',
				    id: 'player'
				});

				$('.js-home-video-container').append(newVideo);

				// Generate new html
				function loadVideoFrame() {
					window.youtubeIframeService.executeOnReady(() => { 
						new YT.Player('player', {
							width: '100%',
							videoId: videoId,
							playerVars: { 'autoplay': 1, 'playsinline': 1, 'rel': 0, 'loop': 1, 'autopause': 0, 'controls': 0, 'showinfo': 0, 'modestbranding': 1, 'branding': 0, 'fs': 0, 'iv_load_policy': 3 },
							events: {
								'onReady': onPlayerReady,
								'onStateChange': onPlayerStateChange
							}
						});
					});
				};
				
				if(videoType == 'autoplay'){
					loadVideoFrame();
				}else{
					$(".js-home-video-image").removeClass("d-md-none fade-in");
					if(customVideoThumb == 'true'){
						setTimeout(function(){
							$(".js-home-video-image").removeClass("d-md-none fade-in");
							$(".js-home-video-image img").attr("src" , customVideoThumbSrc).show();	
						},100);
					}else{
						generateVideoThumb(videoId);
					}
				}

				function onPlayerReady(event) {
					event.target.mute();
					event.target.playVideo();
				}

				function onPlayerStateChange(event) {
					if (event.data === YT.PlayerState.ENDED) {
						if (event.target && typeof event.target.seekTo === "function") {
							event.target.seekTo(0);
							event.target.playVideo();
						} 
					}
				}
			}

			// Update video thumbnail and iframe
			handlers.video_embed = new instaElements.Lambda(function(videoUrl){
				const $section = $('.js-section-video');
				const $container = $('.js-home-video-container');
				if (videoUrl) {
					$section.show();

					// Get video ID to create new iframe
					let videoFormat;
					let videoEmbed = videoUrl;

					if (videoEmbed.includes('/watch?v=')) {
					    videoFormat = '/watch?v=';
					} else if (videoEmbed.includes('/youtu.be/')) {
					    videoFormat = '/youtu.be/';
					} else if (videoEmbed.includes('/shorts/')) {
					    videoFormat = '/shorts/';
					}

					let videoId;
					if (videoFormat) {
					    videoId = videoEmbed.split(videoFormat).pop();
					}

					$('.js-home-video-container').attr("data-video" , videoId);
					
					// Generate new video instance
					generateVideo(videoId);

					// Show container for both video and text and signal thumbnail readiness to placeholder
					$container.attr('data-thumbnail-ready', true).show();

				} else {
					$section.hide().find(".js-home-video").attr("src" , "");
				}
			});

			// Update video type
			handlers.video_type = new instaElements.Lambda(function(videoType){
				const videoId = $('.js-home-video-container').attr('data-video');
				const $videoIframe = $('.js-home-video');
				const $playButton = $('.js-play-button');
				const $videoImage = $('.js-home-video-image');

				if (videoType == 'autoplay') {
					$playButton.hide();
					$videoImage.hide().removeClass('d-block');
					$('.js-home-video-text-container').removeClass("home-video-text-bottom").attr("data-home-video-sound", "false");
					$('.js-home-video-container').attr("data-video-type", "autoplay").attr("data-allow-custom-thumb" , "false");
				} else {
					$playButton.show().removeAttr("style");
					$videoImage.show();
					$('.js-home-video-text-container').addClass("home-video-text-bottom").attr("data-home-video-sound", "true");
					$('.js-home-video-container').attr("data-video-type", "sound").attr("data-allow-custom-thumb" , "true");
				}

				// Generate new video instance
				generateVideo(videoId);
			});

			// Toggle mobile vertical for video
			handlers.video_vertical_mobile = new instaElements.Lambda(function(verticalVideo){
				const $container = $('.js-home-video-container');
				if (verticalVideo) {
					$container.addClass('embed-responsive-1by1');
				} else {
					$container.removeClass('embed-responsive-1by1');
				}
			});

			// Update visibility of text
			function videoContentVisibility(){
				const $container = $('.js-home-video-text-container');
				const hasContent = $container.find('.js-home-video-title').text().trim() || 
						$container.find('.js-home-video-subtitle').text().trim() ||
						$container.find('.js-home-video-text').text().trim() ||
						$container.find('.js-home-video-button').text().trim();
				let videoWithSound = $container.attr("data-home-video-sound");
				
				if(hasContent){
					$container.show();
					if(videoWithSound == 'true'){
						$container.addClass('home-video-text-bottom');
					}else{
						$container.removeClass('home-video-text-bottom');
					}
				}else{
					$container.hide();
				}
			}

			// Update title, description and button for video texts
			['title', 'subtitle', 'text', 'button'].forEach(setting => {
				handlers[`video_${setting}`] = new instaElements.Text({
					element: `.js-home-video-${setting}`,
					show: function(){
						$(this).show();
						videoContentVisibility();
					},
					hide: function(){
						$(this).hide();
						videoContentVisibility();
					},
				});
			});

			// Updates custom thumbnail image
			handlers['video_image.jpg'] = new instaElements.Image({
				element: '.js-home-video-image img',
				show: function() {
					const allowCustomThumbVisibility = $('.js-home-video-container').attr("data-allow-custom-thumb");
					$('.js-home-video-container').attr("data-custom-thumb" , "true");
					$(".js-home-video-image").removeClass("d-md-none fade-in");
					//Show only if video is not on first position or has sound. Position info is not updated live 
					if(allowCustomThumbVisibility == 'true'){
						$(this).show();
					}
				},
				hide: function() {
					const videoId = $('.js-home-video-container').attr('data-video');
					const videoType = $('.js-home-video-container').attr("data-video-type");
					$('.js-home-video-container').attr("data-custom-thumb" , "false");

					//Hide if video has autoplay
					if(videoType == 'autoplay'){
						$(this).hide();
					}else{
						//Generate default thumb if video has sound
						generateVideoThumb(videoId);
					}
				},
			});

			return handlers;
		}
	};
})(jQueryNuvem);