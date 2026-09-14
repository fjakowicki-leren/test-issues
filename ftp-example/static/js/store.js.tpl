{#/*============================================================================
    #Specific store JS functions: product variants, cart, shipping, etc
==============================================================================*/#}

{#/*============================================================================

	Table of Contents

	#Lazy load
	#Notifications and tooltips
	#Modals
	#Cards
	#Accordions
	#Transitions
	#Header and nav
		// Header
		// Nav
		// Search suggestions
	#Sliders
		// Home slider
		// Products slider
		// Main categories
		// Product related
		// Banner services slider
	#Social
		// Youtube video
		// Instagram feed
	#Product grid
		// Fixed category controls
		// Filters
		// Product item slider
		// Infinite scroll
		// Quickshop
	#Product detail functions
		// Installments
		// Change Variant
		// Submit to contact form
		// Product labels on variant change
		// Color and size variants change
		// Custom mobile variants change
		// Submit to contact
		// Product slider
		// Pinterest sharing
		// Add to cart
		// Product quantity
	#Cart
		// Toggle cart 
		// Add to cart
		// Cart quantitiy changes
		// Empty cart alert
	#Shipping calculator
		// Select and save shipping function
		// Calculate shipping function
		// Calculate shipping by submit
		// Shipping and branch click
		// Select shipping first option on results
		// Toggle more shipping options
		// Calculate shipping on page load
		// Shipping provinces
		// Change store country
	#Forms
	#Footer
	#Empty placeholders

==============================================================================*/#}

// Move to our_content
window.urls = {
    "shippingUrl": "{{ store.shipping_calculator_url | escape('js') }}"
}

{#/*============================================================================
  #Lazy load
==============================================================================*/ #}

document.addEventListener('lazybeforeunveil', function(e){
    if ((e.target.parentElement) && (e.target.nextElementSibling)) {
        var parent = e.target.parentElement;
        var sibling = e.target.nextElementSibling;
        if (sibling.classList.contains('js-lazy-loading-preloader')) {
            sibling.style.display = 'none';
            parent.style.display = 'block';
        }
    }
});


window.lazySizesConfig = window.lazySizesConfig || {};
lazySizesConfig.hFac = 0.4;


DOMContentLoaded.addEventOrExecute(() => {

	{#/*============================================================================
	  #Notifications and tooltips
	==============================================================================*/ #}

    {# /* // Close notification and tooltip */ #}

    jQueryNuvem(".js-notification-close, .js-tooltip-close").on( "click", function(e) {
        e.preventDefault();
        jQueryNuvem(e.currentTarget).closest(".js-notification, .js-tooltip").hide();
    });

    {# Notifications variables #}

    var $notification_order_cancellation = jQueryNuvem(".js-notification-order-cancellation");
    var $notification_status_page = jQueryNuvem(".js-notification-status-page");
    var $fixed_bottom_button = jQueryNuvem(".js-btn-fixed-bottom");
    
	{# /* // Follow order status notification */ #}
    
    if ($notification_status_page.length > 0){
        if (LS.shouldShowOrderStatusNotification($notification_status_page.data('url'))){
            $notification_status_page.show();
        };
        jQueryNuvem(".js-notification-status-page-close").on( "click", function(e) {
            e.preventDefault();
            LS.dontShowOrderStatusNotificationAgain($notification_status_page.data('url'));
        });
    }

    {# /* // Cart notification: Dismiss notification */ #}

    jQueryNuvem(".js-cart-notification-close").on("click", function(){
        jQueryNuvem(".js-alert-added-to-cart").removeClass("notification-visible").addClass("notification-hidden");
        setTimeout(function(){
            jQueryNuvem('.js-cart-notification-item-img').attr('src', '');
            jQueryNuvem(".js-alert-added-to-cart").hide();
        },2000);
    });

    {% if not settings.head_fix_desktop %}

        {# /* // Add to cart notification on non fixed header */ #}
        if (window.innerWidth > 768) {
            var topBarHeight = jQueryNuvem(".js-adbar").outerHeight();
            var logoBarHeight = jQueryNuvem(".js-nav-logo-bar").outerHeight();
            var fixedNotificationPosition = topBarHeight + logoBarHeight; 
            var $addedToCartNotification = jQueryNuvem(".js-alert-added-to-cart");

            $addedToCartNotification.css("top", fixedNotificationPosition.toString() + 'px').css("marginTop", "-30px");

            !function () {
                window.addEventListener("scroll", function (e) {
                    if (window.pageYOffset == 0) {
                        $addedToCartNotification.css("top" , fixedNotificationPosition.toString() + 'px').css("marginTop", "-30px");;
                    } else {
                        $addedToCartNotification.css("top" , "20px").css("marginTop", "-10px");;
                    }
                });
            }();
        }

    {% endif %}

    {% if not params.preview %}

        {# /* // Cookie banner notification */ #}

        const footerLegal = jQueryNuvem(".js-footer-legal");

        restoreNotifications = function(){

            // Whatsapp button position
            $fixed_bottom_button.css("marginBottom", "0px");

            {# Restore notifications when Cookie Banner is closed #}

            footerLegal.removeAttr("style");
        };

        if (!window.cookieNotificationService.isAcknowledged()) {
            jQueryNuvem(".js-notification-cookie-banner").show();

            {# Offset to show legal footer #}

            const cookieBannerHeight = jQueryNuvem(".js-notification-cookie-banner").outerHeight();
            footerLegal.css("paddingBottom", cookieBannerHeight + 30 + "px");

            {# Whatsapp button position #}

            $fixed_bottom_button.css("marginBottom", "45px");

        }

        jQueryNuvem(".js-acknowledge-cookies").on( "click", function(e) {
            window.cookieNotificationService.acknowledge();
            restoreNotifications();
        });

    {% endif %}

    setTimeout(() => {
        $fixed_bottom_button.css("opacity", "1");
    }, 1000);

    {#/*============================================================================
      #Modals
    ==============================================================================*/ #}

    {% if settings.quick_shop %}

        restoreQuickshopForm = function(){

            {# Restore form to item when quickshop closes #}

            {# Clean quickshop modal #}

            jQueryNuvem("#quickshop-modal .js-item-product").removeClass("js-swiper-slide-visible js-item-slide");
            jQueryNuvem("#quickshop-modal .js-quickshop-container").attr( { 'data-variants' : '' , 'data-quickshop-id': '' } );
            jQueryNuvem("#quickshop-modal .js-item-product").attr('data-product-id', '');

            {# Wait for modal to become invisible before removing form #}
            
            setTimeout(function(){
                var $quickshop_form = jQueryNuvem("#quickshop-form").find('.js-product-form');
                var $item_form_container = jQueryNuvem(".js-quickshop-opened").find(".js-item-variants");
                
                $quickshop_form.detach().appendTo($item_form_container);
                jQueryNuvem(".js-quickshop-opened").removeClass("js-quickshop-opened");
            },350);

        };

    {% endif %}

    {# Full screen mobile modals back events #}

    if (window.innerWidth < 768) {

        {# Clean url hash function #}

        cleanURLHash = function(){
            const uri = window.location.toString();
            const clean_uri = uri.substring(0, uri.indexOf("#"));
            window.history.replaceState({}, document.title, clean_uri);
        };

        {# Go back 1 step on browser history #}

        goBackBrowser = function(){
            cleanURLHash();
            history.back();
        };

        {# Clean url hash on page load: All modals should be closed on load #}

        if(window.location.href.indexOf("modal-fullscreen") > -1) {
            cleanURLHash();
        }

        {# Open full screen modal and url hash #}

        jQueryNuvem(document).on("click", ".js-fullscreen-modal-open", function(e) {
            e.preventDefault();
            var modal_url_hash = jQueryNuvem(this).data("modalUrl");
            window.location.hash = modal_url_hash;
        });

        {# Close full screen modal: Remove url hash #}

        jQueryNuvem(document).on("click", ".js-fullscreen-modal-close", function(e) {
            e.preventDefault();
            goBackBrowser();
        });

        {# Hide panels or modals on browser backbutton #}

        window.onhashchange = function() {
            if(window.location.href.indexOf("modal-fullscreen") <= -1) {

                {# Close opened modal #}

                if(jQueryNuvem(".js-fullscreen-modal").hasClass("modal-show")){

                    {# Remove body lock only if a single modal is visible on screen #}

                    if(jQueryNuvem(".js-modal.modal-show").length == 1){
                        jQueryNuvem("body").removeClass("overflow-none");
                    }
                    var $opened_modal = jQueryNuvem(".js-fullscreen-modal.modal-show");
                    var $opened_modal_overlay = $opened_modal.prev();

                    $opened_modal.removeClass("modal-show");
                    setTimeout(() => $opened_modal.hide(), 500);
                    $opened_modal_overlay.fadeOut(500);

                    {% if settings.quick_shop %}
                        restoreQuickshopForm();
                    {% endif %}

                }
            }
        }

    }

    modalOpen = function(modal_id){
        var $overlay_id = jQueryNuvem('.js-modal-overlay[data-modal-id="' + modal_id + '"]');

        {# If a tabnav is opened close all other tab modals#}
        if((jQueryNuvem('.js-toggle-tabnav.tabnav-active').length) && (window.innerWidth < 768) && (!jQueryNuvem(this).hasClass("js-open-over-modal"))){
            let tabnav_modals = jQueryNuvem(".js-tabnav-modal");
            jQueryNuvem(tabnav_modals).removeClass("modal-show");
        }

        if (jQueryNuvem(modal_id).hasClass("modal-show")) {
            {# If modal is already opened, close it #}
            if(jQueryNuvem(".js-modal.modal-show").length == 1){
                jQueryNuvem("body").removeClass("overflow-none");
            }
            let modal = jQueryNuvem(modal_id).removeClass("modal-show");
            setTimeout(() => modal.hide(), 500);
        } else {

            {# Lock body scroll if there is no modal visible on screen #}
            
            if(!jQueryNuvem(".js-modal.modal-show").length){
                jQueryNuvem("body").addClass("overflow-none");
            }

            jQueryNuvem(modal_id).detach().appendTo("body");
            jQueryNuvem(modal_id).show().addClass("modal-show");
            
            {# Show overlay for all modals or tab modals only in desktop #}
            if (((jQueryNuvem(modal_id).hasClass("js-modal-overlay-md")) && (window.innerWidth > 768)) || (!jQueryNuvem(modal_id).hasClass("js-modal-overlay-md"))) {
                $overlay_id.fadeIn(400);
                $overlay_id.detach().insertBefore(modal_id);
            }
        }
    };

    jQueryNuvem(document).on("click", ".js-modal-open", function(e) {
        e.preventDefault(); 
        var modal_id = jQueryNuvem(this).data('toggle');
        modalOpen(modal_id);
    });

    jQueryNuvem(document).on("click", ".js-modal-close", function(e) {
        e.preventDefault();

        {# If there is a tabnav closing, remove active class from tab #}
        if((jQueryNuvem('.js-toggle-tabnav.tabnav-active').length) && (!jQueryNuvem(this).hasClass("js-close-over-modal")) && (window.innerWidth < 768)){
            jQueryNuvem('.js-toggle-tabnav.tabnav-active').removeClass("tabnav-active");
        }

        {# Remove body lock only if a single modal is visible on screen #}

        if(jQueryNuvem(".js-modal.modal-show").length == 1){
            jQueryNuvem("body").removeClass("overflow-none");
        }
        var $modal = jQueryNuvem(this).closest(".js-modal");
        var modal_id = $modal.attr('id');
        var $overlay_id = jQueryNuvem('.js-modal-overlay[data-modal-id="#' + modal_id + '"]');
        $modal.removeClass("modal-show");
        setTimeout(() => $modal.hide(), 500);
        $overlay_id.fadeOut(500);
        
        {# Close full screen modal: Remove url hash #}

        if ((window.innerWidth < 768) && (jQueryNuvem(this).hasClass(".js-fullscreen-modal-close"))) {
            goBackBrowser();
        }

        {% if settings.quick_shop %}
            restoreQuickshopForm();
        {% endif %}

    });

    jQueryNuvem(document).on("click", ".js-modal-overlay", function(e) {
        e.preventDefault();

        {# Remove body lock only if a single modal is visible on screen #}

        if(jQueryNuvem(".js-modal.modal-show").length == 1){
            jQueryNuvem("body").removeClass("overflow-none");
        }

        var modal_id = jQueryNuvem(this).data('modalId');
        let modal = jQueryNuvem(modal_id).removeClass("modal-show");
        setTimeout(() => modal.hide(), 500);
        jQueryNuvem(this).fadeOut(500);

        {% if settings.quick_shop %}
            restoreQuickshopForm();
        {% endif %}

    });

    {% if template == 'home' and settings.home_promotional_popup %}

        {# /* // Home popup and newsletter popup */ #}

        jQueryNuvem('#news-popup-form').on("submit", function () {
            jQueryNuvem(".js-news-spinner").show();
            jQueryNuvem(".js-news-send, .js-news-popup-submit").hide();
            jQueryNuvem(".js-news-popup-submit").prop("disabled", true);
        });

        LS.newsletter('#news-popup-form-container', '#home-modal', '{{ store.contact_url | escape('js') }}', function (response) {
            jQueryNuvem(".js-news-spinner").hide();
            jQueryNuvem(".js-news-send, .js-news-popup-submit").show();
            var selector_to_use = response.success ? '.js-news-popup-success' : '.js-news-popup-failed';
            let newPopupAlert = jQueryNuvem(this).find(selector_to_use).fadeIn(100);
            setTimeout(() => newPopupAlert.fadeOut(500), 4000);
            if (jQueryNuvem(".js-news-popup-success").css("display") == "block") {
                setTimeout(function () {
                    jQueryNuvem('[data-modal-id="#home-modal"]').fadeOut(500);
                    let homeModal = jQueryNuvem("#home-modal").removeClass("modal-show");
                    setTimeout(() => homeModal.hide(), 500);
                }, 2500);
            }
            jQueryNuvem(".js-news-popup-submit").prop("disabled", false);
        });

        var callback_show = function(){
            {% if store.whatsapp %}
                jQueryNuvem('.js-btn-fixed-bottom').fadeOut(500);
            {% endif %}
            jQueryNuvem("#home-modal").detach().appendTo("body").show().addClass("modal-show");
        }
        var callback_hide = function(){
            let homeModal = jQueryNuvem("#home-modal").removeClass("modal-show");
            setTimeout(() => homeModal.hide(), 500);
        }

        {% if store.whatsapp %}
            jQueryNuvem("#home-modal .js-modal-close").on("click", function (e) {
                e.preventDefault();
                jQueryNuvem('.js-btn-fixed-bottom').fadeIn(500);
            });
        {% endif %}

        LS.homePopup({
            selector: "#home-modal",
            mobile_max_pixels: 0,
            timeout: 10000
        }, callback_hide, callback_show);

    {% endif %}

    {#/*============================================================================
      #Cards
    ==============================================================================*/ #}
    jQueryNuvem(document).on("click", ".js-card-collapse-toggle", function(e) {
        e.preventDefault();
        jQueryNuvem(this).toggleClass('active');
        jQueryNuvem(this).closest(".js-card-collapse").toggleClass('active');
    });

    {#/*============================================================================
      #Accordions
    ==============================================================================*/ #}

    function toggleAccordion(selector){
        if(jQueryNuvem(selector).hasClass("js-accordion-show-only")){
            jQueryNuvem(selector).hide();
        }else{
            jQueryNuvem(selector).find(".js-accordion-toggle-inactive").toggle();
            jQueryNuvem(selector).find(".js-accordion-toggle-active").toggle();
        }
        jQueryNuvem(selector).closest(".js-accordion-container").find(".js-accordion-content").slideToggle("fast");
    }

    jQueryNuvem(document).on("click", ".js-accordion-toggle", function(e) {
        e.preventDefault();
        toggleAccordion(this);
    });

    if(window.innerWidth < 768){
        jQueryNuvem(document).on("click", ".js-accordion-toggle-mobile", function(e) {
            e.preventDefault();
            toggleAccordion(this);
        });
        jQueryNuvem(".js-accordion-content-mobile").hide();
    }else{
        jQueryNuvem(".js-accordion-toggle-mobile").css("cursor" , "default").removeAttr('href');
    }

    {#/*============================================================================
      #Transitions
    ==============================================================================*/ #}

    const inViewport = (entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting && !entry.target.observed) {
                entry.target.classList.add("is-inViewport");
                entry.target.observed = true;
            }
        });
    };

    // Attach observer to every [data-transition] element:
    const ELs_inViewport = document.querySelectorAll('[data-transition]');
    ELs_inViewport.forEach(EL => {
        EL.observed = false; // Initialize the observed flag for each element
        const Obs = new IntersectionObserver(inViewport);
        Obs.observe(EL);
    });

	{#/*============================================================================
      #Header and nav
    ==============================================================================*/ #}

    {# /* // Adbar slider */ #}

    {% set adbarMessage01 = settings.ad_text %}
    {% set adbarMessage02 = settings.ad_02_text %}
    {% set adbarMessage03 = settings.ad_03_text %}
    {% set adbarMultipleMessages = (adbarMessage01 and adbarMessage02) or (adbarMessage01 and adbarMessage03) or (adbarMessage02 and adbarMessage03) %}

    {% if settings.ad_bar %}

        {% if settings.ad_bar_animate %}

            {# /* // Animated adbar */ #}

                {# Reference speed values #}
                var defaultDelay = 5;
                var defaultWidth = 300;

                {# New speed values based on dynamic content #}
                var animatedAdbarWidth = jQueryNuvem(".js-adbar-text-container").first(el => el.offsetWidth);
                var newDelay = defaultDelay*(animatedAdbarWidth/defaultWidth);

                if((window.innerWidth > 768) && (newDelay < 40)){

                    {# If Adbar is too short, set a minimum speed #}
                    var newDelay = newDelay + 20;
                }

                jQueryNuvem(".js-adbar-animated").css("animation", "marquee " + newDelay + "s linear infinite");

        {% elseif adbarMultipleMessages %}

            createSwiper('.js-swiper-adbar', {
                loop: true,
                slidesPerView: 1,
                navigation: {
                    nextEl: '.js-swiper-adbar-next',
                    prevEl: '.js-swiper-adbar-prev',
                },
            });

        {% endif %}

    {% endif %}

    {# /* // Header */ #}

        {# Transparent head #}

        var fixedNavTransparent = jQueryNuvem(".js-head-mutator");
        var fixedNavTransparentHeight = fixedNavTransparent.height();
        var videoSection = jQueryNuvem(".js-section-video");
        var sliderSection = jQueryNuvem(".js-home-main-slider-container");
        var $category_controls = jQueryNuvem(".js-category-controls");

        {# Components validations #}

        {% set has_main_slider = settings.slider and settings.slider is not empty %}
        {% set has_mobile_slider = settings.toggle_slider_mobile and settings.slider_mobile and settings.slider_mobile is not empty %}
        {% set has_slider = has_main_slider or has_mobile_slider %}
        {% set has_slider_above_the_fold = settings.home_order_position_1 == 'slider' and has_slider %}

        {% set has_video = settings.video_embed or settings.video_embed_mobile %}
        {% set has_video_above_the_fold = settings.home_order_position_1 == 'video' and has_video %}

        {# Remove transparent header when stop swiping #}

        {% set remove_header_transparent_on_scroll_stop = not settings.show_tab_nav and settings.head_transparent and settings.head_transparent_type == 'all' %}

        {% if remove_header_transparent_on_scroll_stop %}

            if (window.innerWidth < 768) {

                {% if template == 'home' and (has_video_above_the_fold or has_slider_above_the_fold) %}
                    {% if has_slider_above_the_fold %}
                        removeTransparentLimit = sliderSection.height();
                    {% else %}
                        removeTransparentLimit = videoSection.height();
                    {% endif %}
                {% else %}
                    removeTransparentLimit = fixedNavTransparentHeight;
                {% endif %}

                var isScrolling;

                window.addEventListener('scroll', function ( event ) {

                    fixedNavTransparent.addClass('head-transparent');
                    $category_controls.addClass('category-controls-transparent');

                    // Clear our timeout throughout the scroll
                    window.clearTimeout(isScrolling);

                    // Set a timeout to run after scrolling ends
                    isScrolling = setTimeout(function() {

                        if((window.scrollY > removeTransparentLimit)){

                            // Stopped scrolling
                            fixedNavTransparent.removeClass('head-transparent');
                            $category_controls.removeClass('category-controls-transparent');
                        }else {

                            // Stopped scrolling on window top
                            fixedNavTransparent.addClass('head-transparent');
                            $category_controls.addClass('category-controls-transparent');
                        }
                    },  500);
                }, false);
            }

        {% endif %}

        {% set toggle_header_transparent_on_hover = settings.filters_desktop_modal and settings.head_fix_desktop and settings.head_transparent and settings.head_transparent_type == 'all' %}

        {% if toggle_header_transparent_on_hover %}

            {# Change header transparent for mouseover on not related elements #}

            if (window.innerWidth > 767) {
                jQueryNuvem(document).on("mouseover", ".js-head-mutator", function(e) {
                    jQueryNuvem(".js-category-controls-transparent-md.is-sticky").addClass("hover");
                }).on("mouseout", ".js-head-mutator", function(e) {
                    jQueryNuvem(".js-category-controls-transparent-md.is-sticky").removeClass("hover");
                });

                jQueryNuvem(document).on("mouseover", ".js-category-controls-transparent-md.is-sticky", function(e) {
                    jQueryNuvem(".js-head-mutator").addClass("hover");
                }).on("mouseout", ".js-category-controls-transparent-md.is-sticky", function(e) {
                    jQueryNuvem(".js-head-mutator").removeClass("hover");
                });
            }

        {% endif %}

        {# Fixed nav #}

    {% set has_one_device_with_fixed_nav = not settings.show_tab_nav or settings.head_fix_desktop %}
    {% set has_only_desktop_with_fixed_nav = settings.show_tab_nav and settings.head_fix_desktop %}
    {% set has_only_mobile_with_fixed_nav = not settings.show_tab_nav and not settings.head_fix_desktop %}

    {% if has_one_device_with_fixed_nav %}
        {% if has_only_mobile_with_fixed_nav %}
            if (window.innerWidth < 768) {
        {% elseif has_only_desktop_with_fixed_nav %}
            if (window.innerWidth > 768) {
        {% endif %}

            {# Slim header on scroll #}

            var navbarHeight = jQueryNuvem(".js-head-main").outerHeight();
            var topbarHeight = jQueryNuvem(".js-adbar").outerHeight();

            window.addEventListener("scroll", function() {

                var scrolledPosition = window.pageYOffset;

                var header = jQueryNuvem(".js-head-main");
                var navbarHeight = header.outerHeight();

                if (scrolledPosition > navbarHeight) {
                    header.addClass('compress').css('top', -topbarHeight + 'px' );
                    {% if template == 'category' or template == 'search' %}
                        if (window.innerWidth < 768) {
                            setTimeout(function(){
                                offsetCategories();
                            },300);
                        }
                    {% endif %}
                } else {
                    header.removeClass('compress').css("top", "0px");
                    {% if template == 'category' or template == 'search' %}
                        if (window.innerWidth < 768) {
                            setTimeout(function(){
                                offsetCategories();
                            },300);
                        }
                    {% endif %}
                }
            });
            
        {% if has_only_mobile_with_fixed_nav or has_only_desktop_with_fixed_nav %}
            }
        {% endif %}
    {% endif %}   

    {# /* // Nav */ #}

        {# Nav subitems hamburger #}

        var $top_nav = jQueryNuvem(".js-mobile-nav");
        var $page_main_content = jQueryNuvem(".js-main-content");
        var $search_backdrop = jQueryNuvem(".js-search-backdrop");

        $top_nav.addClass("move-down").removeClass("move-up");

        jQueryNuvem(".js-toggle-menu-panel").click(function (e) {
            e.preventDefault();
            jQueryNuvem(this).next(".js-menu-panel").show().addClass("nav-list-panel-show");
        });

        jQueryNuvem(".js-toggle-menu-back").click(function (e) {
            e.preventDefault();
            var $panel_to_change = jQueryNuvem(this).closest(".js-menu-panel");
            $panel_to_change.removeClass("nav-list-panel-show");
             setTimeout(function(){
                $panel_to_change.hide();
            },600);
        });

        closeHamburgerSubpanels = function() {
            {% if settings.show_tab_nav %}
                if (window.innerWidth < 768) {
                    jQueryNuvem(".js-menu-panel").addClass("nav-list-panel-bottom-hide");
                }else {
                    jQueryNuvem(".js-menu-panel").removeClass("nav-list-panel-show");
                }
            {% else %}
                jQueryNuvem(".js-menu-panel").removeClass("nav-list-panel-show");
            {% endif %}
            
             setTimeout(function(){
                jQueryNuvem(".js-menu-panel").hide();
                {% if settings.show_tab_nav %}
                    if (window.innerWidth < 768) {
                        jQueryNuvem(".js-menu-panel").removeClass("nav-list-panel-show nav-list-panel-bottom-hide");
                    }
                {% endif %}
            },1000);
        };

        jQueryNuvem(".js-toggle-menu-close, .js-modal-overlay[data-modal-id='#nav-hamburger'").click(function () {
            closeHamburgerSubpanels();
        });

        {# Nav subitems desktop #}

        var win_height = window.innerHeight;
        var head_height = jQueryNuvem(".js-head-main").height();

        jQueryNuvem(".js-desktop-dropdown").css('maxHeight', (win_height - head_height - 50).toString() + 'px');

        jQueryNuvem(".js-item-desktop").on("mouseenter", function (e) {
            jQueryNuvem(e.currentTarget).addClass("active");
        }).on("mouseleave", function(e) {
            jQueryNuvem(e.currentTarget).removeClass("active");
        });

        jQueryNuvem(".js-item-desktop").on("mouseenter", function (e) {
            jQueryNuvem('.js-nav-desktop-list').children(".selected").removeClass("selected");
            jQueryNuvem(e.currentTarget).addClass("selected");
        }).on("mouseleave", function(e) {
            const self = jQueryNuvem(this);
            setTimeout(function(){
                self.removeClass("selected");
            },500);
        });

        {# Avoid megamenu dropdown flickering when mouse leave #}

        jQueryNuvem(".js-desktop-dropdown").on("mouseleave", function (e) {
            const self = jQueryNuvem(this);
            self.css("pointer-events" , "none");
            setTimeout(function(){
                self.css("pointer-events" , "initial");
            },1000);
        });

        {# Focus search #}

        jQueryNuvem(".js-search-button").on("click", function (e) {
            setTimeout(function(){
                jQueryNuvem("#nav-search .js-search-input").each(el => el.focus());
            },10);
        });

        {% if settings.show_tab_nav %}
            
            {# Tabnav #}

            jQueryNuvem(".js-toggle-tabnav").on("click", function (e) {
                e.preventDefault();
                if (jQueryNuvem(this).hasClass("tabnav-active")) {
                    jQueryNuvem(this).removeClass("tabnav-active");
                    if(jQueryNuvem(this).hasClass("js-cart-tab")){
                        jQueryNuvem(".js-cart-widget-amount").show();
                    }
                }else{
                    jQueryNuvem(".js-toggle-tabnav").removeClass("tabnav-active");
                    jQueryNuvem(this).addClass("tabnav-active");
                    if(jQueryNuvem(this).hasClass("js-cart-tab")){
                        jQueryNuvem(".js-cart-widget-amount").hide();
                    }else {
                        jQueryNuvem(".js-cart-widget-amount").show();
                    }
                    
                }
                closeHamburgerSubpanels();         
            });

            jQueryNuvem(".js-open-cart").on("click", function (e) {
                e.preventDefault();
                jQueryNuvem(".js-cart-tab").addClass("tabnav-active");
                if (window.innerWidth < 768) {
                    jQueryNuvem(".js-cart-widget-amount").hide();
                }   
            });

            jQueryNuvem("#modal-cart .js-modal-close").on("click", function (e) {
                e.preventDefault();
                if (window.innerWidth < 768) {
                    jQueryNuvem(".js-cart-widget-amount").show();
                }     
            });

        {% endif %}

    {# /* // Search suggestions */ #}

        LS.search(jQueryNuvem(".js-search-input"), function (html, count) {
            $search_suggests = jQueryNuvem(this).closest(".js-search-container").next(".js-search-suggest");
            if (count > 0) {
                $search_suggests.html(html).show();
            } else {
                $search_suggests.hide();
            }
            if (jQueryNuvem(this).val().length == 0) {
                $search_suggests.hide();
            }
        }, {
            snipplet: 'header/header-search-results.tpl'
        });

        if (window.innerWidth > 768) {

            {# Hide search suggestions if user click outside results #}

            jQueryNuvem("body").on("click", function () {
                jQueryNuvem(".js-search-suggest").hide();
            });

            {# Maintain search suggestions visibility if user click on links inside #}

            jQueryNuvem(document).on("click", ".js-search-suggest a", function () {
                jQueryNuvem(".js-search-suggest").show();
            });
        }

        jQueryNuvem(".js-search-suggest").on("click", ".js-search-suggest-all-link", function (e) {
            e.preventDefault();
            $this_closest_form = jQueryNuvem(this).closest(".js-search-suggest").prev(".js-search-form");
            $this_closest_form.submit();
        });

    {# /* // Lang select */ #}


    changeLang = function(element) {
        var selected_country_url = element.find("option").filter((el) => el.selected).attr("data-country-url");
        location.href = selected_country_url;
    };

    jQueryNuvem('.js-lang-select').on("change", function (e) {
        lang_select_option = jQueryNuvem(this);

        changeLang(lang_select_option);
    });


	{#/*============================================================================
	  #Sliders
	==============================================================================*/ #}

    {% set theme_editor = params.preview %}
    {% set columns_desktop = settings.grid_columns_desktop %}
    {% set columns_mobile = settings.grid_columns_mobile %}
    var slidesPerViewDesktopVal = {% if columns_desktop == 2 %}2{% elseif columns_desktop == 3 %}3{% else %}4{% endif %};
    var slidesPerViewMobileVal = {% if columns_mobile == 1 %}1.15{% elseif columns_mobile == 2 %}2.25{% else %}3.25{% endif %};
    var itemSwiperSpaceBetween = 15;

    {# Hide arrow controls when swiper is not swipable #}

    hideSwiperControls = function(elemPrev, elemNext) {
        if((jQueryNuvem(elemPrev).hasClass("swiper-button-disabled") && jQueryNuvem(elemNext).hasClass("swiper-button-disabled"))){
            jQueryNuvem(elemPrev).remove();
            jQueryNuvem(elemNext).remove();
        }
    };

	{% if template == 'home' %}

		{# /* // Home slider */ #}


        var width = window.innerWidth;
        if (width > 767) {
            var slider_autoplay = {delay: 6000,};
        } else {
            var slider_autoplay = false;
        }

        var preloadImagesValue = false;
        var lazyValue = true;
        var loopValue = true;
        var paginationClickableValue = true;

        createSwiper(
            '.js-home-slider', {
                preloadImages: preloadImagesValue,
                lazy: lazyValue,
                {% if settings.slider | length > 1 %}
                    loop: loopValue,
                {% endif %}
                autoplay: slider_autoplay,
                pagination: {
                    el: '.js-swiper-home-pagination',
                    clickable: paginationClickableValue,
                },
                navigation: {
                    nextEl: '.js-swiper-home-next',
                    prevEl: '.js-swiper-home-prev',
                },
            },
            function(swiperInstance) {
                window.homeSwiper = swiperInstance;
            }
        );

        createSwiper(
            '.js-home-slider-mobile', {
                preloadImages: preloadImagesValue,
                lazy: lazyValue,
                {% if settings.slider_mobile | length > 1 %}
                    loop: loopValue,
                {% endif %}
                autoplay: slider_autoplay,
                pagination: {
                    el: '.js-swiper-home-pagination-mobile',
                    clickable: paginationClickableValue,
                },
                navigation: {
                    nextEl: '.js-swiper-home-next-mobile',
                    prevEl: '.js-swiper-home-prev-mobile',
                },
            },
            function(swiperInstance) {
                window.homeMobileSwiper = swiperInstance;
            }
        );

        {% if settings.slider | length == 1 %}
            jQueryNuvem('.js-swiper-home .swiper-wrapper').addClass( "disabled" );
            jQueryNuvem('.js-swiper-home-pagination, .js-swiper-home-prev, .js-swiper-home-next').remove();
        {% endif %}

        {# /* // Products slider */ #}

        {% set has_featured_products_slider = sections.primary.products and settings.featured_products_format != 'grid' %}
        {% set has_new_products_slider = sections.new.products and settings.new_products_format != 'grid' %}
        {% set has_sale_products_slider = sections.sale.products and settings.sale_products_format != 'grid' %}

        {% if (has_featured_products_slider or has_new_products_slider or has_sale_products_slider) or theme_editor %}

            var lazyVal = true;
            var watchOverflowVal = true;
            var centerInsufficientSlidesVal = true;

            {% if has_featured_products_slider or theme_editor %}

                {% set featured_columns_desktop = settings.featured_products_desktop %}
                {% set featured_columns_mobile = settings.featured_products_mobile %}
                var slidesPerViewFeaturedDesktopVal = {% if featured_columns_desktop == 4 %}4{% elseif featured_columns_desktop == 3 %}3{% elseif featured_columns_desktop == 2 %}2{% else %}slidesPerViewDesktopVal{% endif %};
                var slidesPerViewFeaturedMobileVal = {% if featured_columns_mobile == 1 %}1.15{% elseif featured_columns_mobile == 2 %}2.25{% elseif featured_columns_mobile == 3 %}3.25{% else %}slidesPerViewMobileVal{% endif %};

                createSwiper('.js-swiper-featured', {
                    lazy: lazyVal,
                    watchOverflow: watchOverflowVal,
                    centerInsufficientSlides: centerInsufficientSlidesVal,
                    threshold: 5,
                    watchSlideProgress: true,
                    watchSlidesVisibility: true,
                    slideVisibleClass: 'js-swiper-slide-visible',
                    spaceBetween: itemSwiperSpaceBetween,
                {% if sections.primary.products | length > 3 %}
                    loop: true,
                {% endif %}
                    navigation: {
                        nextEl: '.js-swiper-featured-next',
                        prevEl: '.js-swiper-featured-prev',
                    },
                    slidesPerView: slidesPerViewFeaturedMobileVal,
                    breakpoints: {
                        768: {
                            slidesPerView: slidesPerViewFeaturedDesktopVal,
                        }
                    }
                },

                function(swiperInstance) {
                    window.productsFeaturedSwiper = swiperInstance;
                });

            {% endif %}

            {% if has_new_products_slider or theme_editor %}

                {% set new_columns_desktop = settings.new_products_desktop %}
                {% set new_columns_mobile = settings.new_products_mobile %}
                var slidesPerViewNewDesktopVal = {% if new_columns_desktop == 4 %}4{% elseif new_columns_desktop == 3 %}3{% elseif new_columns_desktop == 2 %}2{% else %}slidesPerViewDesktopVal{% endif %};
                var slidesPerViewNewMobileVal = {% if new_columns_mobile == 1 %}1.15{% elseif new_columns_mobile == 2 %}2.25{% elseif new_columns_mobile == 3 %}3.25{% else %}slidesPerViewMobileVal{% endif %};

                createSwiper('.js-swiper-new', {
                    lazy: lazyVal,
                    watchOverflow: watchOverflowVal,
                    centerInsufficientSlides: centerInsufficientSlidesVal,
                    threshold: 5,
                    watchSlideProgress: true,
                    watchSlidesVisibility: true,
                    slideVisibleClass: 'js-swiper-slide-visible',
                    spaceBetween: itemSwiperSpaceBetween,
                {% if sections.new.products | length > 3 %}
                    loop: true,
                {% endif %}
                    navigation: {
                        nextEl: '.js-swiper-new-next',
                        prevEl: '.js-swiper-new-prev',
                    },
                    slidesPerView: slidesPerViewNewMobileVal,
                    breakpoints: {
                        768: {
                            slidesPerView: slidesPerViewNewDesktopVal,
                        }
                    }
                },

                function(swiperInstance) {
                    window.productsNewSwiper = swiperInstance;
                });

            {% endif %}

            {% if has_sale_products_slider or theme_editor %}

                {% set sale_columns_desktop = settings.sale_products_desktop %}
                {% set sale_columns_mobile = settings.sale_products_mobile %}
                var slidesPerViewSaleDesktopVal = {% if sale_columns_desktop == 4 %}4{% elseif sale_columns_desktop == 3 %}3{% elseif sale_columns_desktop == 2 %}2{% else %}slidesPerViewDesktopVal{% endif %};
                var slidesPerViewSaleMobileVal = {% if sale_columns_mobile == 1 %}1.15{% elseif sale_columns_mobile == 2 %}2.25{% elseif sale_columns_mobile == 3 %}3.25{% else %}slidesPerViewMobileVal{% endif %};

                createSwiper('.js-swiper-sale', {
                    lazy: lazyVal,
                    watchOverflow: watchOverflowVal,
                    centerInsufficientSlides: centerInsufficientSlidesVal,
                    threshold: 5,
                    watchSlideProgress: true,
                    watchSlidesVisibility: true,
                    slideVisibleClass: 'js-swiper-slide-visible',
                    spaceBetween: itemSwiperSpaceBetween,
                {% if sections.sale.products | length > 3 %}
                    loop: true,
                {% endif %}
                    navigation: {
                        nextEl: '.js-swiper-sale-next',
                        prevEl: '.js-swiper-sale-prev',
                    },
                    slidesPerView: slidesPerViewSaleMobileVal,
                    breakpoints: {
                        768: {
                            slidesPerView: slidesPerViewSaleDesktopVal,
                        }
                    }
                },

                function(swiperInstance) {
                    window.productsSaleSwiper = swiperInstance;
                });

            {% endif %}

        {% endif %}

        {# /* // Home demo products slider */ #}

        window.swiperLoader('.js-swiper-featured-demo', {
            lazy: true,
            loop: true,
            watchOverflow: true,
            centerInsufficientSlides: true,
            slidesPerView: slidesPerViewMobileVal,
            spaceBetween: itemSwiperSpaceBetween,
            navigation: {
                nextEl: '.js-swiper-featured-demo-next',
                prevEl: '.js-swiper-featured-demo-prev',
            },
            breakpoints: {
                768: {
                    slidesPerView: slidesPerViewDesktopVal,
                }
            }
        });

        {# /* // Banners slider */ #}

        {# Category banners #}

        {% if settings.banner_slider or theme_editor %}

            {% set banner_columns_desktop = settings.banner_columns_desktop %}
            {% set banner_columns_mobile = settings.banner_columns_mobile %}

            var bannersPerViewDesktopVal = {% if banner_columns_desktop == 5 %}5{% elseif banner_columns_desktop == 4 %}4{% elseif banner_columns_desktop == 3 %}3{% elseif banner_columns_desktop == 2 %}2{% else %}1{% endif %};
            var bannersPerViewMobileVal = {% if banner_columns_mobile == 2 %}2{% else %}1.15{% endif %};

            {# General banners #}

            {% if (settings.banner and settings.banner is not empty) or theme_editor %}

                createSwiper('.js-swiper-banners', {
                    lazy: true,
                    watchOverflow: true,
                    threshold: 5,
                    watchSlideProgress: true,
                    watchSlidesVisibility: true,
                    slideVisibleClass: 'js-swiper-slide-visible',
                    spaceBetween: itemSwiperSpaceBetween,
                    autoplay: {
                        delay: 2000,
                    },
                    navigation: {
                        nextEl: '.js-swiper-banners-next',
                        prevEl: '.js-swiper-banners-prev',
                    },
                    slidesPerView: bannersPerViewMobileVal,
                    breakpoints: {
                        768: {
                            slidesPerView: bannersPerViewDesktopVal,
                            autoplay: false,
                        }
                    },
                },
                function(swiperInstance) {
                    window.homeBannerSwiper = swiperInstance;
                });
            {% endif %}

            {# Mobile banners #}

            {% if (settings.toggle_banner_mobile and settings.banner_mobile and settings.banner_mobile is not empty) or theme_editor %}

                createSwiper('.js-swiper-banners-mobile', {
                    lazy: true,
                    watchOverflow: true,
                    threshold: 5,
                    watchSlideProgress: true,
                    watchSlidesVisibility: true,
                    slideVisibleClass: 'js-swiper-slide-visible',
                    spaceBetween: itemSwiperSpaceBetween,
                    navigation: {
                        nextEl: '.js-swiper-banners-mobile-next',
                        prevEl: '.js-swiper-banners-mobile-prev',
                    },
                    slidesPerView: bannersPerViewMobileVal,
                    breakpoints: {
                        768: {
                            slidesPerView: bannersPerViewDesktopVal,
                        }
                    },
                },
                function(swiperInstance) {
                    window.homeBannerMobileSwiper = swiperInstance;
                });
            {% endif %}

        {% endif %}

        {# Promotional banners #}

        {% if settings.banner_promotional_slider or theme_editor %}

            {% set banner_promotional_columns_desktop = settings.banner_promotional_columns_desktop %}
            {% set banner_promotional_columns_mobile = settings.banner_promotional_columns_mobile %}

            var bannersPromotionalPerViewDesktopVal = {% if banner_promotional_columns_desktop == 4 %}4{% elseif banner_promotional_columns_desktop == 3 %}3{% elseif banner_promotional_columns_desktop == 2 %}2{% else %}1{% endif %};
            var bannersPromotionalPerViewMobileVal = {% if banner_promotional_columns_mobile == 2 %}2.25{% else %}1.15{% endif %};

            {# General banners #}

            {% if (settings.banner_promotional and settings.banner_promotional is not empty) or theme_editor %}

                createSwiper('.js-swiper-banners-promotional', {
                    lazy: true,
                    watchOverflow: true,
                    threshold: 5,
                    watchSlideProgress: true,
                    watchSlidesVisibility: true,
                    slideVisibleClass: 'js-swiper-slide-visible',
                    spaceBetween: itemSwiperSpaceBetween,
                    navigation: {
                        nextEl: '.js-swiper-banners-promotional-next',
                        prevEl: '.js-swiper-banners-promotional-prev',
                    },
                    slidesPerView: bannersPromotionalPerViewMobileVal,
                    breakpoints: {
                        768: {
                            slidesPerView: bannersPromotionalPerViewDesktopVal,
                        }
                    },
                },
                function(swiperInstance) {
                    window.homeBannerPromotionalSwiper = swiperInstance;
                });

            {% endif %}

            {# Mobile banners #}

            {% if (settings.toggle_banner_promotional_mobile and settings.banner_promotional_mobile and settings.banner_promotional_mobile is not empty) or theme_editor %}

                createSwiper('.js-swiper-banners-promotional-mobile', {
                    lazy: true,
                    watchOverflow: true,
                    threshold: 5,
                    watchSlideProgress: true,
                    watchSlidesVisibility: true,
                    slideVisibleClass: 'js-swiper-slide-visible',
                    spaceBetween: itemSwiperSpaceBetween,
                    navigation: {
                        nextEl: '.js-swiper-banners-promotional-mobile-next',
                        prevEl: '.js-swiper-banners-promotional-mobile-prev',
                    },
                    slidesPerView: bannersPromotionalPerViewMobileVal,
                    breakpoints: {
                        768: {
                            slidesPerView: bannersPromotionalPerViewDesktopVal,
                        }
                    },
                },
                function(swiperInstance) {
                    window.homeBannerPromotionalMobileSwiper = swiperInstance;
                });

            {% endif %}

        {% endif %}

        {# News banners #}

        {% if settings.banner_news_slider or theme_editor %}

            {% set banner_news_columns_desktop = settings.banner_news_columns_desktop %}
            {% set banner_news_columns_mobile = settings.banner_news_columns_mobile %}

            var bannersNewsPerViewDesktopVal = {% if banner_news_columns_desktop == 4 %}4{% elseif banner_news_columns_desktop == 3 %}3{% elseif banner_news_columns_desktop == 2 %}2{% else %}1{% endif %};
            var bannersNewsPerViewMobileVal = {% if banner_news_columns_mobile == 2 %}2.25{% else %}1.15{% endif %};

            {# General banners #}

            {% if (settings.banner_news and settings.banner_news is not empty) or theme_editor %}

                createSwiper('.js-swiper-banners-news', {
                    lazy: true,
                    watchOverflow: true,
                    threshold: 5,
                    watchSlideProgress: true,
                    watchSlidesVisibility: true,
                    slideVisibleClass: 'js-swiper-slide-visible',
                    spaceBetween: itemSwiperSpaceBetween,
                    navigation: {
                        nextEl: '.js-swiper-banners-news-next',
                        prevEl: '.js-swiper-banners-news-prev',
                    },
                    slidesPerView: bannersNewsPerViewMobileVal,
                    breakpoints: {
                        768: {
                            slidesPerView: bannersNewsPerViewDesktopVal,
                        }
                    },
                },
                function(swiperInstance) {
                    window.homeBannerNewsSwiper = swiperInstance;
                });

            {% endif %}

            {# Mobile banners #}

            {% if (settings.toggle_banner_news_mobile and settings.banner_news_mobile and settings.banner_news_mobile is not empty) or theme_editor %}

                createSwiper('.js-swiper-banners-news-mobile', {
                    lazy: true,
                    watchOverflow: true,
                    threshold: 5,
                    watchSlideProgress: true,
                    watchSlidesVisibility: true,
                    slideVisibleClass: 'js-swiper-slide-visible',
                    spaceBetween: itemSwiperSpaceBetween,
                    navigation: {
                        nextEl: '.js-swiper-banners-news-mobile-next',
                        prevEl: '.js-swiper-banners-news-mobile-prev',
                    },
                    slidesPerView: bannersNewsPerViewMobileVal,
                    breakpoints: {
                        768: {
                            slidesPerView: bannersNewsPerViewDesktopVal,
                        }
                    },
                },
                function(swiperInstance) {
                    window.homeBannerNewsMobileSwiper = swiperInstance;
                });

            {% endif %}

        {% endif %}

        {# Image and text modules #}

        {% if (settings.module_slider or theme_editor and (settings.module and settings.module is not empty)) or theme_editor %}

            createSwiper('.js-swiper-modules', {
                lazy: true,
                watchOverflow: true,
                threshold: 5,
                watchSlideProgress: true,
                watchSlidesVisibility: true,
                slideVisibleClass: 'js-swiper-slide-visible',
                spaceBetween: itemSwiperSpaceBetween,
                centerInsufficientSlides: true,
                navigation: {
                    nextEl: '.js-swiper-modules-next',
                    prevEl: '.js-swiper-modules-prev',
                },
                slidesPerView: 1.15,
                breakpoints: {
                    768: {
                        slidesPerView: 1,
                    }
                },
                on: {
                    afterInit: function () {
                        hideSwiperControls(".js-swiper-modules-prev", ".js-swiper-modules-next");
                    },
                },
            },
            function(swiperInstance) {
                window.homeModuleSwiper = swiperInstance;
            });

        {% endif %}

        {% if settings.show_instafeed and store.instagram and store.hasInstagramToken() %}
            createSwiper('.js-swiper-instafeed', {
                lazy: true,
                watchOverflow: true,
                spaceBetween: itemSwiperSpaceBetween,
                slidesPerView: 2.25,
                observer: true,
                breakpoints: {
                    640: {
                        slidesPerView: 6,
                    }
                }
            });
        {% endif %}

        {# /* // Main categories */ #}

        {% if settings.main_categories %}

            createSwiper('.js-swiper-categories', {
                lazy: true,
                preloadImages : false,
                watchOverflow: true,
                watchSlidesVisibility : true,
                slidesPerView: 'auto',
                centerInsufficientSlides: true,
                navigation: {
                    nextEl: '.js-swiper-categories-next',
                    prevEl: '.js-swiper-categories-prev',
                },
            });

        {% endif %}

        createSwiper('.js-swiper-categories-demo', {
            watchOverflow: true,
            watchSlidesVisibility : true,
            slidesPerView: 'auto',
            centerInsufficientSlides: true,
            navigation: {
                nextEl: '.js-swiper-categories-demo-next',
                prevEl: '.js-swiper-categories-demo-prev',
            },
        });

        {# /* // Testimonials slider */ #}

        {% set has_testimonial_01 = settings.testimonial_01_description or settings.testimonial_01_name or "testimonial_01.jpg" | has_custom_image %}
        {% set has_testimonial_02 = settings.testimonial_02_description or settings.testimonial_02_name or "testimonial_02.jpg" | has_custom_image %}
        {% set has_testimonial_03 = settings.testimonial_03_description or settings.testimonial_03_name or "testimonial_03.jpg" | has_custom_image %}

        {% if (has_testimonial_01 or has_testimonial_02 or has_testimonial_03) or theme_editor %}

            createSwiper('.js-swiper-testimonials', {
                lazy: true,
                watchOverflow: true,
                centerInsufficientSlides: true,
                threshold: 5,
                spaceBetween: 20,
                slidesPerView: 1,
                pagination: {
                    el: '.js-swiper-testimonials-pagination',
                    clickable: true,
                },
                breakpoints: {
                    768: {
                        slidesPerView: 3,
                    }
                }
            },
            function(swiperInstance) {
                window.testimonialsSwiper = swiperInstance;
            });

        {% endif %}

        {# Swiper used for demo component #}

        createSwiper('.js-swiper-testimonials-demo', {
             lazy: true,
            watchOverflow: true,
            centerInsufficientSlides: true,
            threshold: 5,
            spaceBetween: 20,
            slidesPerView: 1,
            pagination: {
                el: '.js-swiper-testimonials-demo-pagination',
                clickable: true,
            },
            breakpoints: {
                768: {
                    slidesPerView: 3,
                }
            }
        });

        {# /* // Brands slider */ #}

        createSwiper('.js-swiper-brands', {
            lazy: true,
            watchOverflow: true,
            threshold: 5,
            slidesPerView: 'auto',
            loop: true,
            autoplay: {
                delay: 2000,
            },
            spaceBetween: 16,
            navigation: {
                nextEl: '.js-swiper-brands-next',
                prevEl: '.js-swiper-brands-prev',
            },
            breakpoints: {
                768: {
                    slidesPerView: 'auto',
                    spaceBetween: 24,
                }
            },
        },function(swiperInstance) {
            window.brandsSwiper = swiperInstance;
        });

        {# Swiper used for demo component #}

        createSwiper('.js-swiper-empty-brands', {
            lazy: true,
            watchOverflow: true,
            threshold: 5,
            slidesPerView: 1.25,
            spaceBetween: 16,
            navigation: {
                nextEl: '.js-swiper-empty-brands-next',
                prevEl: '.js-swiper-empty-brands-prev',
            },
            breakpoints: {
                768: {
                    slidesPerView: 5,
                    spaceBetween: 24,
                }
            },
        });

        {# /* // Home videos carousel */ #}

        {% if sections.videos.products %}

            var homeVideosSwiper = null;
            var homeVideosInitDone = false;
            var homeVideoHoverSlide = null;

            function renderHomeVideoDots(swiper, total) {
                var dotsWrap = document.querySelector('.js-home-videos-dots');
                if (!dotsWrap || !swiper || total <= 1) return;
                var activeIndex = swiper.params.loop ? swiper.realIndex : swiper.activeIndex;
                dotsWrap.innerHTML = '';
                for (var i = 0; i < total; i++) {
                    var dot = document.createElement('button');
                    dot.type = 'button';
                    dot.className = 'home-videos__dot' + (i === activeIndex ? ' is-active' : '');
                    dot.setAttribute('aria-label', 'Ir al slide ' + (i + 1));
                    dot.dataset.index = i;
                    dot.onclick = function () {
                        var idx = parseInt(this.dataset.index, 10);
                        if (swiper.params.loop) swiper.slideToLoop(idx);
                        else swiper.slideTo(idx);
                    };
                    dotsWrap.appendChild(dot);
                }
            }

            function updateHomeVideoDots(swiper, total) {
                var activeIndex = swiper.params.loop ? swiper.realIndex : swiper.activeIndex;
                var dots = document.querySelectorAll('.js-home-videos-dots .home-videos__dot');
                dots.forEach(function (dot, i) {
                    dot.classList.toggle('is-active', i === activeIndex);
                });
            }

            var HOME_VIDEO_PRELOAD_MS = 3000;
            var HOME_VIDEO_READY_DELAY_MS = 500;
            var homeVideoScheduleTimers = [];

            function clearHomeVideoScheduleTimers() {
                homeVideoScheduleTimers.forEach(clearTimeout);
                homeVideoScheduleTimers = [];
            }

            function deferHomeVideoSchedule(fn, delay) {
                var id = setTimeout(fn, delay);
                homeVideoScheduleTimers.push(id);
            }

            function isHomeVideoSlidePlaying(slide) {
                var media = slide && slide.querySelector('.home-videos__media--video');
                return !!(media && media.classList.contains('is-playing'));
            }

            function postHomeVideoCommand(iframe, command) {
                if (!iframe || !iframe.contentWindow) return;
                var provider = iframe.dataset.videoProvider;
                if (provider === 'youtube') {
                    iframe.contentWindow.postMessage(JSON.stringify({
                        event: 'command',
                        func: command,
                        args: ''
                    }), '*');
                } else if (provider === 'vimeo') {
                    iframe.contentWindow.postMessage(JSON.stringify({ method: command }), '*');
                }
            }

            function playHomeVideo(iframe) {
                postHomeVideoCommand(iframe, iframe.dataset.videoProvider === 'youtube' ? 'playVideo' : 'play');
            }

            function pauseHomeVideo(iframe) {
                postHomeVideoCommand(iframe, iframe.dataset.videoProvider === 'youtube' ? 'pauseVideo' : 'pause');
            }

            function ensureHomeVideoPlaying(iframe) {
                if (!iframe) return;
                playHomeVideo(iframe);
                var attempts = 0;
                var retryTimer = setInterval(function () {
                    var slide = iframe.closest('.home-videos__slide');
                    if (!slide || !isHomeVideoSlidePlaying(slide) || attempts++ >= 12) {
                        clearInterval(retryTimer);
                        return;
                    }
                    playHomeVideo(iframe);
                }, 200);
            }

            function preloadHomeVideo(iframe, urgent) {
                if (!iframe) return;
                if (iframe.dataset.videoLoaded !== '1') {
                    deferHomeVideoSchedule(function () { preloadHomeVideo(iframe, urgent); }, urgent ? 80 : 250);
                    return;
                }
                var state = iframe.dataset.preloadState;
                if (state === 'ready') return;
                if (state === 'loading') {
                    if (urgent) playHomeVideo(iframe);
                    return;
                }
                iframe.dataset.preloadState = 'loading';

                playHomeVideo(iframe);

                setTimeout(function () {
                    var slide = iframe.closest('.home-videos__slide');
                    if (!isHomeVideoSlidePlaying(slide)) {
                        pauseHomeVideo(iframe);
                    }
                    iframe.dataset.preloadState = 'ready';
                }, HOME_VIDEO_PRELOAD_MS);
            }

            function cancelNonPriorityHomeVideoPreloads(container, priorityIframe) {
                if (!container || !priorityIframe) return;
                container.querySelectorAll('.home-videos__iframe').forEach(function (iframe) {
                    if (iframe === priorityIframe) return;
                    if (iframe.dataset.preloadState !== 'loading') return;
                    var slide = iframe.closest('.home-videos__slide');
                    if (isHomeVideoSlidePlaying(slide)) return;
                    pauseHomeVideo(iframe);
                    iframe.dataset.preloadState = '';
                });
            }

            function getHomeVideoPrioritySlide(container, swiper) {
                if (homeVideoHoverSlide && container.contains(homeVideoHoverSlide)) {
                    return homeVideoHoverSlide;
                }
                if (swiper && swiper.slides && swiper.slides[swiper.activeIndex]) {
                    return swiper.slides[swiper.activeIndex];
                }
                return container.querySelector('.swiper-slide-active');
            }

            function getHomeVideoSecondarySlides(container, swiper, prioritySlide) {
                var slides = [];
                if (!swiper || !swiper.slides) return slides;
                [-1, 1].forEach(function (offset) {
                    var slide = swiper.slides[swiper.activeIndex + offset];
                    if (slide && slide !== prioritySlide) slides.push(slide);
                });
                return slides;
            }

            function refreshHomeVideoPreloadPriority(container, swiper) {
                if (!container) return;
                clearHomeVideoScheduleTimers();

                var prioritySlide = getHomeVideoPrioritySlide(container, swiper);
                var priorityIframe = prioritySlide && prioritySlide.querySelector('.home-videos__iframe');
                var isHoverPriority = !!(homeVideoHoverSlide && prioritySlide === homeVideoHoverSlide);

                if (priorityIframe) {
                    cancelNonPriorityHomeVideoPreloads(container, priorityIframe);
                    deferHomeVideoSchedule(function () {
                        preloadHomeVideo(priorityIframe, true);
                    }, isHoverPriority ? 0 : HOME_VIDEO_READY_DELAY_MS);
                }

                getHomeVideoSecondarySlides(container, swiper, prioritySlide).forEach(function (slide, index) {
                    var iframe = slide.querySelector('.home-videos__iframe');
                    if (!iframe) return;
                    deferHomeVideoSchedule(function () {
                        preloadHomeVideo(iframe, false);
                    }, HOME_VIDEO_READY_DELAY_MS + 1400 + index * 700);
                });
            }

            function bindHomeVideoIframe(iframe) {
                if (!iframe || iframe.dataset.videoBound === '1') return;
                iframe.dataset.videoBound = '1';

                var markLoaded = function () {
                    iframe.dataset.videoLoaded = '1';
                };

                var queuePreload = function () {
                    markLoaded();
                    var container = iframe.closest('.js-swiper-home-videos');
                    refreshHomeVideoPreloadPriority(container, homeVideosSwiper);
                };

                iframe.addEventListener('load', function () {
                    if (iframe.dataset.videoProvider === 'youtube') {
                        setTimeout(function () {
                            iframe.contentWindow.postMessage(JSON.stringify({
                                event: 'listening',
                                id: iframe.dataset.videoId,
                                channel: 'widget'
                            }), '*');
                        }, 100);
                    }
                    queuePreload();
                }, { once: true });

                setTimeout(function () {
                    if (iframe.dataset.videoLoaded !== '1') queuePreload();
                }, HOME_VIDEO_READY_DELAY_MS + 800);
            }

            function bindHomeVideoIframes(container) {
                if (!container) return;
                container.querySelectorAll('.home-videos__iframe').forEach(bindHomeVideoIframe);
            }

            function syncHomeVideoPlayback(swiper) {
                var container = document.querySelector('.js-swiper-home-videos');
                if (!container) return;
                var targetSlide = getHomeVideoPrioritySlide(container, swiper);
                container.querySelectorAll('.home-videos__slide').forEach(function (slide) {
                    var iframe = slide.querySelector('.home-videos__iframe');
                    var media = slide.querySelector('.home-videos__media--video');
                    if (!iframe || !media) return;
                    var shouldPlay = slide === targetSlide;
                    if (shouldPlay) {
                        ensureHomeVideoPlaying(iframe);
                        media.classList.add('is-playing');
                    } else {
                        pauseHomeVideo(iframe);
                        media.classList.remove('is-playing');
                    }
                });
            }

            function initHomeVideosSlider(container) {
                var HOME_VIDEOS_TOTAL = container.querySelectorAll('.home-videos__slide').length;
                if (homeVideosInitDone || HOME_VIDEOS_TOTAL <= 0) {
                    if (HOME_VIDEOS_TOTAL <= 0) {
                        var emptySection = document.querySelector('.section-home-videos');
                        if (emptySection) emptySection.style.display = 'none';
                    }
                    return;
                }
                if (container.swiper) container.swiper.destroy(true, true);
                homeVideosInitDone = true;

                var videosOptions = {
                    slidesPerView: 1.5,
                    centeredSlides: true,
                    spaceBetween: 12,
                    watchOverflow: false,
                    threshold: 5,
                    observer: true,
                    observeParents: true,
                    watchSlidesVisibility: true,
                    slideVisibleClass: 'js-swiper-slide-visible',
                    loopAdditionalSlides: 5,
                    loopedSlides: HOME_VIDEOS_TOTAL,
                    navigation: {
                        nextEl: '.js-swiper-home-videos-next',
                        prevEl: '.js-swiper-home-videos-prev',
                    },
                    breakpoints: {
                        768: {
                            slidesPerView: 5,
                            spaceBetween: 16
                        }
                    }
                };
                if (HOME_VIDEOS_TOTAL > 1) videosOptions.loop = true;

                createSwiper('.js-swiper-home-videos', videosOptions, function (swiper) {
                    homeVideosSwiper = swiper;
                    swiper.update();
                    requestAnimationFrame(function () { swiper.update(); });
                    bindHomeVideoIframes(container);
                    renderHomeVideoDots(swiper, HOME_VIDEOS_TOTAL);
                    swiper.on('slideChange', function () { updateHomeVideoDots(swiper, HOME_VIDEOS_TOTAL); });
                    swiper.on('slideChangeTransitionStart', function () {
                        homeVideoHoverSlide = null;
                        container.querySelectorAll('.home-videos__media--video').forEach(function (media) {
                            media.classList.remove('is-playing');
                        });
                        container.querySelectorAll('.home-videos__iframe').forEach(pauseHomeVideo);
                    });
                    swiper.on('slideChangeTransitionEnd', function () {
                        refreshHomeVideoPreloadPriority(container, swiper);
                        syncHomeVideoPlayback(swiper);
                    });
                    refreshHomeVideoPreloadPriority(container, swiper);
                    setTimeout(function () { syncHomeVideoPlayback(swiper); }, 600);
                });
            }

            var homeVideosContainer = document.querySelector('.js-swiper-home-videos');
            if (homeVideosContainer) {
                initHomeVideosSlider(homeVideosContainer);
            }

        {% endif %}

	{% endif %}

    {% if template == 'product' %}

        {# /* // Product Related */ #}

        function calculateRelatedLoopVal(sectionSelector) {
            let productsAmount = jQueryNuvem(sectionSelector).attr("data-related-amount");
            let loopVal = false;
            const applyLoop = (window.innerWidth < 768 && productsAmount > slidesPerViewMobileVal) || (window.innerWidth > 768 && productsAmount > slidesPerViewDesktopVal);
            
            if (applyLoop) {
                loopVal = true;
            }

            return loopVal;
        }

        let alternativeLoopVal = calculateRelatedLoopVal(".js-related-products");
        let complementaryLoopVal = calculateRelatedLoopVal(".js-complementary-products");

        {# Alternative products #}

        createSwiper('.js-swiper-related', {
            lazy: true,
            loop: alternativeLoopVal,
            watchOverflow: true,
            centerInsufficientSlides: true,
            threshold: 5,
            watchSlideProgress: true,
            watchSlidesVisibility: true,
            slideVisibleClass: 'js-swiper-slide-visible',
            spaceBetween: itemSwiperSpaceBetween,
            slidesPerView: slidesPerViewMobileVal,
            navigation: {
                nextEl: '.js-swiper-related-next',
                prevEl: '.js-swiper-related-prev',
            },
            breakpoints: {
                768: {
                    slidesPerView: slidesPerViewDesktopVal,
                }
            }
        });

        {# Complementary products #}

        createSwiper('.js-swiper-complementary', {
            lazy: true,
            loop: complementaryLoopVal,
            watchOverflow: true,
            centerInsufficientSlides: true,
            threshold: 5,
            watchSlideProgress: true,
            watchSlidesVisibility: true,
            slideVisibleClass: 'js-swiper-slide-visible',
            spaceBetween: itemSwiperSpaceBetween,
            slidesPerView: slidesPerViewMobileVal,
            navigation: {
                nextEl: '.js-swiper-complementary-next',
                prevEl: '.js-swiper-complementary-prev',
            },
            breakpoints: {
                768: {
                    slidesPerView: slidesPerViewDesktopVal,
                }
            }
        });


    {% endif %}



	{% set has_banner_services = settings.banner_services %}

	{% if has_banner_services %}

		{# /* // Banner services slider */ #}

        var width = window.innerWidth;
        if (width < 767) {
            createSwiper('.js-informative-banners', {
                slidesPerView: 1,
                watchOverflow: true,
                centerInsufficientSlides: true,
                pagination: {
                    el: '.js-informative-banners-pagination',
                    clickable: true,
                },
                breakpoints: {
                    640: {
                        slidesPerView: 3,
                    }
                }
            });
        }

    {% endif %}

	{#/*============================================================================
	  #Social
	==============================================================================*/ #}

    {% if template == 'home' and (settings.video_embed or settings.video_embed_mobile) %}

        {# /* // Home native video: YouTube or Vimeo, desktop + mobile */ #}

        function ensureVimeoPlayerApi(callback) {
            if (window.Vimeo && window.Vimeo.Player) {
                callback();
                return;
            }
            if (window._vimeoPlayerApiLoading) {
                window._vimeoPlayerApiLoading.push(callback);
                return;
            }
            window._vimeoPlayerApiLoading = [callback];
            var script = document.createElement('script');
            script.src = 'https://player.vimeo.com/api/player.js';
            script.async = true;
            script.onload = function () {
                var queue = window._vimeoPlayerApiLoading || [];
                window._vimeoPlayerApiLoading = null;
                queue.forEach(function (cb) { cb(); });
            };
            document.head.appendChild(script);
        }

        function loadHomeNativeVideoFrame(el) {
            if (!el || el.dataset.videoLoaded === 'true') return;

            var provider = el.getAttribute('data-video-provider');
            var videoId = el.getAttribute('data-video');
            var videoType = el.getAttribute('data-video-type');
            var playerMount = el.querySelector('.js-home-video');
            if (!provider || !videoId || !playerMount) return;

            el.dataset.videoLoaded = 'true';

            if (provider === 'youtube') {
                window.youtubeIframeService.executeOnReady(function () {
                    new YT.Player(playerMount.id, {
                        width: '100%',
                        videoId: videoId,
                        playerVars: {
                            autoplay: 1,
                            playsinline: 1,
                            rel: 0,
                            loop: 1,
                            autopause: 0,
                            controls: 0,
                            showinfo: 0,
                            modestbranding: 1,
                            branding: 0,
                            fs: 0,
                            iv_load_policy: 3,
                            playlist: videoId
                        },
                        events: {
                            onReady: function (event) {
                                if (videoType === 'autoplay') {
                                    event.target.mute();
                                }
                                event.target.playVideo();
                            },
                            onStateChange: function (event) {
                                {% if settings.home_order_position_1 == 'video' %}
                                if (event.data == YT.PlayerState.PLAYING) {
                                    jQueryNuvem(el).find('.js-home-video-image').addClass('fade-in');
                                }
                                {% endif %}
                                if (event.data == YT.PlayerState.ENDED) {
                                    event.target.seekTo(0);
                                    event.target.playVideo();
                                }
                            }
                        }
                    });
                });
                return;
            }

            if (provider === 'vimeo') {
                var autoplay = videoType === 'autoplay';
                var src = 'https://player.vimeo.com/video/' + videoId +
                    '?api=1&loop=1&playsinline=1&title=0&byline=0&portrait=0&dnt=1' +
                    (autoplay ? '&background=1&autoplay=1&muted=1&controls=0' : '&autoplay=0&muted=0&controls=1');

                var iframe = document.createElement('iframe');
                iframe.className = 'js-home-video-iframe embed-responsive-item';
                iframe.src = src;
                iframe.setAttribute('allow', 'autoplay; fullscreen; picture-in-picture');
                iframe.setAttribute('allowfullscreen', '');
                iframe.setAttribute('frameborder', '0');
                iframe.style.cssText = 'position:absolute;top:0;left:0;width:100%;height:100%;border:0;';
                playerMount.appendChild(iframe);

                ensureVimeoPlayerApi(function () {
                    var player = new Vimeo.Player(iframe);
                    if (autoplay) {
                        player.setMuted(true).then(function () {
                            return player.play();
                        }).catch(function () {});
                    } else {
                        player.play().catch(function () {});
                    }
                    {% if settings.home_order_position_1 == 'video' %}
                    player.on('play', function () {
                        jQueryNuvem(el).find('.js-home-video-image').addClass('fade-in');
                    });
                    {% endif %}
                });
            }
        }

        function initVisibleHomeVideos() {
            var isDesktop = window.innerWidth >= 768;
            document.querySelectorAll('.js-home-video-container').forEach(function (el) {
                var viewport = el.getAttribute('data-video-viewport');
                if ((isDesktop && viewport === 'mobile') || (!isDesktop && viewport === 'desktop')) {
                    return;
                }
                loadHomeNativeVideoFrame(el);
            });
        }

        {% if settings.home_order_position_1 == 'video' and settings.video_type == 'autoplay' %}
            if (window.innerWidth < 768) {
                window.addEventListener('pointerdown', function () {
                    initVisibleHomeVideos();
                }, { once: true });
            } else {
                initVisibleHomeVideos();
            }
        {% else %}
            {% if settings.video_type == 'autoplay' %}
                jQueryNuvem('.js-home-video-container').on('lazyloaded', function (e) {
                    var el = e.currentTarget || this;
                    var isDesktop = window.innerWidth >= 768;
                    var viewport = el.getAttribute('data-video-viewport');
                    if ((isDesktop && viewport === 'mobile') || (!isDesktop && viewport === 'desktop')) {
                        return;
                    }
                    loadHomeNativeVideoFrame(el);
                });
            {% else %}
                jQueryNuvem('.js-home-video-container .js-play-button').on('click', function (e) {
                    e.preventDefault();
                    var $container = jQueryNuvem(this).closest('.js-home-video-container');
                    var el = $container[0] || $container.get(0) || document.querySelector('.js-home-video-container[data-video-viewport="' + (window.innerWidth >= 768 ? 'desktop' : 'mobile') + '"]');
                    if (!el) {
                        el = this.closest('.js-home-video-container');
                    }
                    var $playButton = $container.find('.js-play-button');
                    $playButton.css('opacity', '0');
                    setTimeout(function () {
                        $playButton.css('height', '0');
                    }, 200);
                    $container.find('.js-home-video-image').hide();
                    loadHomeNativeVideoFrame(el);
                });
            {% endif %}
        {% endif %}

        window.addEventListener('resize', function () {
            {% if settings.video_type == 'autoplay' %}
            initVisibleHomeVideos();
            {% endif %}
        });

    {% endif %}

    {% if template == 'product' and product.video_url %}
        {% set video_url = product.video_url %}
        {# /* // Youtube or Vimeo video for home or each product */ #}
        LS.loadVideo('{{ video_url }}');
    {% endif %}


	{#/*============================================================================
	  #Product grid
	==============================================================================*/ #}

    var nav_height = jQueryNuvem(".js-head-main").innerHeight();

	{% if template == 'category' or template == 'search' %}

        {# /* // Fixed category controls listener */ #}

        {% if not settings.filters_desktop_modal %}
            if (window.innerWidth < 768) {
        {% endif %}

                {% if settings.show_tab_nav %}
                    $category_controls.css("top" , "0");
                {% else %}
                    $category_controls.css("top" , nav_height.toString() + 'px');
                {% endif %}

                {# Detect if category controls are sticky and add css #}

                var observer = new IntersectionObserver(function(entries) {
                    if(entries[0].intersectionRatio === 0)
                        $category_controls.addClass("is-sticky");
                    else if(entries[0].intersectionRatio === 1)
                        $category_controls.removeClass("is-sticky");
                    }, { threshold: [0,1]
                });
                observer.observe(document.querySelector(".js-category-controls-prev"));

                offsetCategories = function() {
                    var $sticky_category_controls = jQueryNuvem(".js-category-controls");

                    var categoriesOffset = jQueryNuvem(".js-head-main").outerHeight();

                    {% set desktop_relative_header = not settings.head_fix_desktop and settings.filters_desktop_modal %}
                    {% set mobile_tab_nav = settings.show_tab_nav %}
                    {% if mobile_tab_nav or desktop_relative_header %}
                        {% if desktop_relative_header and not mobile_tab_nav %}
                            if (window.innerWidth > 768) {
                        {% elseif mobile_tab_nav and not desktop_relative_header %}
                            if (window.innerWidth < 768) {
                        {% endif %}
                                var categoriesOffset = 0;
                        {% if (desktop_relative_header and not mobile_tab_nav) or (mobile_tab_nav and not desktop_relative_header) %}
                            }
                        {% endif %}
                    {% endif %}

                    if(jQueryNuvem(".js-head-main").hasClass("compress")){
                        var categoriesOffset = categoriesOffset - topbarHeight;
                    }

                    {% set desktop_sticky_categories_under_header = settings.filters_desktop_modal and settings.head_fix_desktop %}
                    {% set desktop_only_sticky_categories_under_header = desktop_sticky_categories_under_header and settings.show_tab_nav %}

                    {% if not settings.show_tab_nav or settings.filters_desktop_modal %}
                        {% if desktop_only_sticky_categories_under_header %}
                            if (window.innerWidth > 768) {
                        {% elseif not (settings.show_tab_nav or settings.filters_desktop_modal) %}
                            if (window.innerWidth < 768) {
                        {% endif %}
                               $sticky_category_controls.css('top', (categoriesOffset).toString() + 'px' );
                        {% if desktop_only_sticky_categories_under_header or not (settings.show_tab_nav or settings.filters_desktop_modal) %}
                           }
                        {% endif %}
                    {% endif %}
                };

                offsetCategories();

                document.addEventListener("scroll", function(){
                    offsetCategories();
                });

        {% if not settings.filters_desktop_modal %}
            }
        {% endif %}

        {# /* // Filters */ #}

        jQueryNuvem(document).on("click", ".js-apply-filter, .js-remove-filter", function(e) {
            e.preventDefault();
            var filter_name = jQueryNuvem(this).attr('data-filter-name');
            var filter_value = jQueryNuvem(this).attr('data-filter-value');
            if(jQueryNuvem(this).hasClass("js-apply-filter")){
                jQueryNuvem(this).find("[type=checkbox]").prop("checked", true);
                LS.urlAddParam(
                    filter_name,
                    filter_value,
                    true
                );
            }else{
                jQueryNuvem(this).find("[type=checkbox]").prop("checked", false);
                LS.urlRemoveParam(
                    filter_name,
                    filter_value
                );
            }

            {# Toggle class to avoid adding double parameters in case of double click and show applying changes feedback #}

            if (jQueryNuvem(this).hasClass("js-filter-checkbox")){
                if (window.innerWidth < 768) {
                    jQueryNuvem(".js-filters-overlay").show();
                    if(jQueryNuvem(this).hasClass("js-apply-filter")){
                        jQueryNuvem(".js-applying-filter").show();
                    }else{
                        jQueryNuvem(".js-removing-filter").show();
                    }
                }
                jQueryNuvem(this).toggleClass("js-apply-filter js-remove-filter");
            }
        });

        jQueryNuvem(document).on("click", ".js-remove-all-filters", function(e) {
            e.preventDefault();
            LS.urlRemoveAllParamsExceptQuerySort();
        });

	{% endif %}

    {% set has_item_slider = settings.product_item_slider %}

    {% if template == 'category' or template == 'search' %}

        {# /* // Product item slider */ #}

        {% if has_item_slider %}

            LS.productItemSlider();

        {% endif %}
    
        !function() {

            {# /* // Infinite scroll */ #}

            {% if pages.current == 1 and not pages.is_last %}
                LS.hybridScroll({
                    productGridSelector: '.js-product-table',
                    spinnerSelector: '#js-infinite-scroll-spinner',
                    loadMoreButtonSelector: '.js-load-more',
                    hideWhileScrollingSelector: ".js-hide-footer-while-scrolling",
                    productsBeforeLoadMoreButton: 50,
                    productsPerPage: 12,
                    afterLoaded: function(){
                        jQueryNuvem('.js-item-product').addClass('is-inViewport');
                        
                        {% if has_item_slider %}
                        
                            LS.productItemSlider();

                        {% endif %}
                    },
                });
            {% endif %}
        }();

    {% endif %}

    {# /* // Variants without stock */ #}

    {% set is_button_variant = settings.bullet_variants %}

    {% if is_button_variant %}
        const noStockVariants = (container = null) => {

            {# Configuration for variant elements #}
            const config = {
                variantsGroup: ".js-product-variants-group",
                variantButton: ".js-insta-variant",
                noStockClass: "btn-variant-no-stock",
                dataVariationId: "data-variation-id",
                dataOption: "data-option"
            };

            {# Product container wrapper #}
            const wrapper = container ? container : jQueryNuvem('#single-product');
            if (!wrapper) return;

            {# Fetch the variants data from the container #}
            const dataVariants = wrapper.data('variants');
            const variantsLength = wrapper.find(config.variantsGroup).length;

            {# Get selected options from product variations #}
            const getOptions = (productVariationId, variantOption) => {
                if (productVariationId === 2) {
                    return {
                        option0: String(wrapper.find(`${config.variantsGroup}[${config.dataVariationId}="0"] select`).val()),
                        option1: String(wrapper.find(`${config.variantsGroup}[${config.dataVariationId}="1"] select`).val()),
                        option2: String(jQueryNuvem(variantOption).attr('data-option')),
                    };
                } else if (productVariationId === 1) {
                    return {
                        option0: String(wrapper.find(`${config.variantsGroup}[${config.dataVariationId}="0"] select`).val()),
                        option1: String(jQueryNuvem(variantOption).attr('data-option')),
                    };
                } else {
                    return {
                        option0: String(jQueryNuvem(variantOption).attr('data-option')),
                    };
                }
            };

            {# Filter available variants based on selected options #}
            const filterVariants = (options) => {
                return dataVariants.filter(variant => {
                    return Object.keys(options).every(optionKey => variant[optionKey] === options[optionKey]) && variant.available;
                });
            };

            {# Update stock status for variant buttons #}
            const updateStockStatus = (productVariationId) => {
                const variationGroup = wrapper.find(`${config.variantsGroup}[${config.dataVariationId}="${productVariationId}"]`);
                variationGroup.find(`${config.variantButton}.${config.noStockClass}`).removeClass(config.noStockClass);

                variationGroup.find(config.variantButton).each((variantOption, item) => {
                    const options = getOptions(productVariationId, variantOption);
                    const itemsAvailable = filterVariants(options);
                    const button = wrapper.find(`${config.variantsGroup}[${config.dataVariationId}="${productVariationId}"] ${config.variantButton}[${config.dataOption}="${options[`option${productVariationId}`].replace(/"/g, '\\"')}"]`);
                    
                    if (!itemsAvailable.length) {
                        button.addClass(config.noStockClass);
                    }
                });
            };

            {# Iterate through all variant and update stock status #}
            for (let productVariationId = variantsLength - 1; productVariationId >= 0; productVariationId--) {
                updateStockStatus(productVariationId);
            }
        };

        noStockVariants();

    {% endif %}

    {% if settings.quick_shop %}

        {% if settings.quick_shop_type == 'popup' %}
            
            {# /* // Modal quickshop */ #}

            jQueryNuvem(document).on("click", ".js-quickshop-modal-open", function (e) {
                e.preventDefault();
                var $this = jQueryNuvem(this);
                if($this.hasClass("js-quickshop-slide")){
                    jQueryNuvem("#quickshop-modal .js-item-product").addClass("js-swiper-slide-visible js-item-slide");
                }

                {% if is_button_variant %}
                    {# Updates variants without stock #}
                    let container = jQueryNuvem(this).closest('.js-quickshop-container');
                    if (!container.length) return;
                    noStockVariants(container);
                {% endif %}

                LS.fillQuickshop($this);
            });

        {% else %}

            {# /* // Inline quickshop */ #}

            jQueryNuvem(document).on("click", ".js-item-buy-open", function(e) {

                {% if is_button_variant %}
                    {# Updates variants without stock #}
                    let container = jQueryNuvem(this).closest('.js-quickshop-container');
                    if (!container.length) return;
                    noStockVariants(container);
                {% endif %}

                if (window.innerWidth < 768) {
                    var $this = jQueryNuvem(this);
                    modalOpen('#quickshop-modal');
                    LS.fillQuickshop($this);
                } else {
                    jQueryNuvem(this).hide();
                    jQueryNuvem(this).closest(".js-item-product").find(".js-item-buy-close").show();
                    jQueryNuvem(this).closest(".js-item-product").find(".js-item-variants").toggleClass("item-variants-hidden").addClass("item-variants-active");
                }

                {# /* // Scrolls up smoothly to the product container if it's above the current viewport */ #}

                var elementTop = jQueryNuvem(this).closest(".js-product-container").offset().top;
                var viewportTop = window.pageYOffset;

                if(elementTop < viewportTop){
                    document.documentElement.scroll({
                        top: jQueryNuvem(this).closest(".js-product-container").offset().top - 100,
                        behavior: 'smooth'
                    });
                }
                
            });

            jQueryNuvem(document).on("click", ".js-item-buy-close", function(e) {
                if (window.innerWidth > 767) {
                    jQueryNuvem(this).hide();
                    jQueryNuvem(this).closest(".js-item-product").find(".js-item-buy-open").show();
                    jQueryNuvem(this).closest(".js-item-product").find(".js-item-variants").toggleClass("item-variants-hidden").removeClass("item-variants-active");
                }
            });

        {% endif %}

    {% endif %}

    {% if settings.bullet_variants or settings.product_color_variants %}
        changeVariantButton = function(selector, parentSelector) {
            selector.siblings().removeClass("selected");
            selector.addClass("selected");
            var option_id = selector.attr('data-option');
            var parent = selector.closest(parentSelector);
            var selected_option = parent.find('.js-variation-option option').filter(function (el) {
                return el.value == option_id;
            });
            selected_option.prop('selected', true).trigger('change');
        }

        {% if settings.bullet_variants %}

            {# /* // Color and size variations */ #}

            jQueryNuvem(document).on("click", ".js-insta-variant", function (e) {
                e.preventDefault();
                $this = jQueryNuvem(this);
                changeVariantButton($this, '.js-product-variants-group');
            });

        {% endif %}

        {% if settings.product_color_variants %}

            {# Product color variations #}
            if (window.innerWidth > 767) {
                jQueryNuvem(document).on("click", ".js-color-variant", function(e) {
                    e.preventDefault();
                    $this = jQueryNuvem(this);
                    changeVariantButton($this, '.js-item-product');
                });
            }
        {% endif %}

    {% endif %}

    {% if settings.quick_shop or settings.product_color_variants %}

        LS.registerOnChangeVariant(function(variant){
            const productContainer = jQueryNuvem('.js-item-product[data-product-id="'+variant.product_id+'"]');
            const current_image = productContainer.find('.js-item-image');
            current_image.attr('srcset', variant.image_url);

            {# Show product image on color change #}

            {% if has_item_slider %}

                {# Remove slider when variant changes #}

                const swiperElement = productContainer.find('.js-product-item-slider-container-private.swiper-container-initialized');

                if(swiperElement.length){
                    productContainer.find('.js-product-item-slider-slide-private').removeClass('item-image-slide');
                    setTimeout(function(){
                        const productImageLink = productContainer.find('.js-product-item-image-link-private');
                        const imageToKeep = productContainer.find('.js-swiper-slide-visible img').clone();
                        
                        // Destroy the Swiper instance
                        if (itemProductSliders[variant.product_id]) {
                            itemProductSliders[variant.product_id].destroy(true, true);
                            delete itemProductSliders[variant.product_id];
                        }
                        // Remove the Swiper elements
                        swiperElement.remove();
                        productContainer.find('.js-product-item-slider-pagination-container-private').remove();
                         
                        // Insert the cloned image into the link
                        productImageLink.append(imageToKeep);
                        
                    },300);
                }
            {% endif %}
            
            {% if settings.product_hover %}
                {# Remove secondary feature on image updated from changeVariant #}
                productContainer.find(".js-product-item-private-with-secondary-images").addClass("product-item-secondary-images-disabled");
            {% endif %}
        });

    {% endif %}

    {#/*============================================================================
	  #Product detail functions
	==============================================================================*/ #}

	{# /* // Installments */ #}

	{# Installments without interest #}

	function get_max_installments_without_interests(number_of_installment, installment_data, max_installments_without_interests) {
	    if (parseInt(number_of_installment) > parseInt(max_installments_without_interests[0])) {
	        if (installment_data.without_interests) {
	            return [number_of_installment, installment_data.installment_value.toFixed(2)];
	        }
	    }
	    return max_installments_without_interests;
	}

	{# Installments with interest #}

	function get_max_installments_with_interests(number_of_installment, installment_data, max_installments_with_interests) {
	    if (parseInt(number_of_installment) > parseInt(max_installments_with_interests[0])) {
	        if (installment_data.without_interests == false) {
	            return [number_of_installment, installment_data.installment_value.toFixed(2)];
	        }
	    }
	    return max_installments_with_interests;
	}

	{# Updates installments on payment popup for native integrations #}

	function refreshInstallmentv2(price){
        jQueryNuvem(".js-modal-installment-price" ).each(function( el ) {
	        const installment = Number(jQueryNuvem(el).data('installment'));
	        jQueryNuvem(el).text(LS.currency.display_short + (price/installment).toLocaleString('de-DE', {maximumFractionDigits: 2, minimumFractionDigits: 2}));
	    });
	}

	{# /* // Change variant */ #}

	{# Updates price, installments, labels and CTA on variant change #}

	function formatMoneyNoCents(price) {
		if (!price) {
			return price;
		}
		return String(price).replace(/[.,]\d{2}(?!\d)/, '');
	}

	function changeVariant(variant) {
        jQueryNuvem(".js-product-detail .js-shipping-calculator-response").hide();
        jQueryNuvem("#shipping-variant-id").val(variant.id);

	    var parent = jQueryNuvem("body");
	    if (variant.element) {
            parent = jQueryNuvem(variant.element);
            if(parent.hasClass("js-quickshop-container")){
                var quick_id = parent.attr("data-quickshop-id");
                var parent = jQueryNuvem('.js-quickshop-container[data-quickshop-id="'+quick_id+'"]');
            }
	    }

        {% if is_button_variant %}
            {# Updates variants without stock #}
            if(parent.hasClass("js-quickshop-container")){
                var itemContainer = parent.closest('.js-item-product');
                if(itemContainer.hasClass("js-item-slide")){
                    var parent = jQueryNuvem('.js-swiper-slide-visible .js-quickshop-container[data-quickshop-id="'+quick_id+'"]');
                }
                noStockVariants(parent);
            } else {
                noStockVariants();
            }
        {% endif %}

	    var sku = parent.find('#sku');
	    if(sku.length) {
	        sku.text(variant.sku).show();
	    }

	    {% if settings.product_stock %}
	        var stock = parent.find('.js-product-stock');
	        stock.text(variant.stock).show();
	    {% endif %}

        {# Updates installments on list item and inside payment popup for Payments Apps #}

	    var installment_helper = function($element, amount, price){
	        $element.find('.js-installment-amount').text(amount);
	        $element.find('.js-installment-price').attr("data-value", price);
	        $element.find('.js-installment-price').text(LS.currency.display_short + parseFloat(price).toLocaleString('de-DE', { minimumFractionDigits: 2 }));
	        if(variant.price_short && Math.abs(variant.price_number - price * amount) < 1) {
	            $element.find('.js-installment-total-price').text((variant.price_short).toLocaleString('de-DE', { minimumFractionDigits: 2 }));
	        } else {
	            $element.find('.js-installment-total-price').text(LS.currency.display_short + (price * amount).toLocaleString('de-DE', { minimumFractionDigits: 2 }));
	        }
	    };

	    var $payments_module = jQueryNuvem(variant.element + ' .js-product-payments-container');

	    if (variant.installments_data) {
	        var variant_installments = JSON.parse(variant.installments_data);
	        var max_installments_without_interests = [0,0];
	        var max_installments_with_interests = [0,0];

	        {# Hide all installments rows on payments modal #}
	        jQueryNuvem('.js-payment-provider-installments-row').hide();

	        for (let payment_method in variant_installments) {

	            {# Identifies the minimum installment value #}
	            var paymentMethodId = '#installment_' + payment_method.replace(" ", "_") + '_1';
	            var minimumInstallmentValue = jQueryNuvem(paymentMethodId).closest('.js-info-payment-method').attr("data-minimum-installment-value");

                let installments = variant_installments[payment_method];
	            for (let number_of_installment in installments) {
                    let installment_data = installments[number_of_installment];
	                max_installments_without_interests = get_max_installments_without_interests(number_of_installment, installment_data, max_installments_without_interests);
	                max_installments_with_interests = get_max_installments_with_interests(number_of_installment, installment_data, max_installments_with_interests);
	                var installment_container_selector = '#installment_' + payment_method.replace(" ", "_") + '_' + number_of_installment;

	                {# Shows installments rows on payments modal according to the minimum value #}
	                if(minimumInstallmentValue <= installment_data.installment_value) {
	                    jQueryNuvem(installment_container_selector).show();
	                }

	                if(!parent.hasClass("js-quickshop-container")){
	                    installment_helper(jQueryNuvem(installment_container_selector), number_of_installment, installment_data.installment_value.toFixed(2));
	                }
	            }
	        }
	        var $installments_container = jQueryNuvem(variant.element + ' .js-max-installments-container .js-max-installments');
	        var $installments_modal_link = jQueryNuvem(variant.element + ' #btn-installments');
	        var $installmens_card_icon = jQueryNuvem(variant.element + ' .js-installments-credit-card-icon');

	        {% if product.has_direct_payment_only %}
	        var installments_to_use = max_installments_without_interests[0] >= 1 ? max_installments_without_interests : max_installments_with_interests;

	        if(installments_to_use[0] <= 0 ) {
	        {%  else %}
	        var installments_to_use = max_installments_without_interests[0] > 1 ? max_installments_without_interests : max_installments_with_interests;

	        if(installments_to_use[0] <= 1 ) {
	        {% endif %}
	            $installments_container.hide();
	            $installments_modal_link.hide();
	            $payments_module.hide();
	            $installmens_card_icon.hide();
	        } else {
	            $installments_container.show();
	            $installments_modal_link.show();
	            $payments_module.show();
	            $installmens_card_icon.show();
	            installment_helper($installments_container, installments_to_use[0], installments_to_use[1]);
	        }
	    }

	    if (variant.contact) {
	        $payments_module.hide();
	    }

	    if(!parent.hasClass("js-quickshop-container")){
            jQueryNuvem('#installments-modal .js-installments-one-payment').text(variant.price_short).attr("data-value", variant.price_number);
		}

	    if (variant.price_short){
	        var price_to_show = parent.hasClass("js-quickshop-container") ? formatMoneyNoCents(variant.price_short) : variant.price_short;
	        parent.find('.js-price-display').text(price_to_show).show();
	        parent.find('.js-price-display').attr("content", variant.price_number).data('productPrice', variant.price_number_raw);

            parent.find('.js-price-without-taxes').text(variant.price_without_taxes);
            parent.find('.js-price-without-taxes-container').show();
	    } else {
	        parent.find('.js-price-display, .js-price-without-taxes-container').hide();
	    }

	    if ((variant.compare_at_price_short) && !(parent.find(".js-price-display").css("display") == "none")) {
	        var compare_price_to_show = parent.hasClass("js-quickshop-container") ? formatMoneyNoCents(variant.compare_at_price_short) : variant.compare_at_price_short;
	        parent.find('.js-compare-price-display').text(compare_price_to_show).show();
	    } else {
	        parent.find('.js-compare-price-display').hide();
	    }

	    var button = parent.find('.js-addtocart');
	    button.removeClass('cart').removeClass('contact').removeClass('nostock');
	    var $product_shipping_calculator = parent.find("#product-shipping-container");

        {# Update CTA wording and status #}

	    {% if not store.is_catalog %}
	    if (!variant.available){
	        button.val('{{ "Sin stock" | translate }}');
	        button.addClass('nostock');
	        button.attr('disabled', 'disabled');
	        $product_shipping_calculator.hide();
	    } else if (variant.contact) {
	        button.val('{{ "Consultar precio" | translate }}');
	        button.addClass('contact');
	        button.removeAttr('disabled');
	        $product_shipping_calculator.hide();
	    } else {
	        button.val('{{ "Agregar al carrito" | translate }}');
	        button.addClass('cart');
	        button.removeAttr('disabled');
	        $product_shipping_calculator.show();
	    }

	    {% endif %}

        {% if template == 'product' %}
            const base_price = Number(jQueryNuvem("#price_display").attr("content"));
            refreshInstallmentv2(base_price);
        {% endif %}

        {% if settings.last_product %}
            if(variant.stock == 1) {
                parent.find('.js-last-product').show();
            } else {
                parent.find('.js-last-product').hide();
            }
        {% endif %}

        {# Update shipping on variant change #}

        LS.updateShippingProduct();

        zipcode_on_changevariant = jQueryNuvem("#product-shipping-container .js-shipping-input").val();
        jQueryNuvem("#product-shipping-container .js-shipping-calculator-current-zip").text(zipcode_on_changevariant);

        {% if cart.free_shipping.min_price_free_shipping.min_price %}
            {# Updates free shipping bar #}

            LS.freeShippingProgress(true, parent);

        {% endif %}

        LS.subscriptionChangeVariant(variant);
	}

	{# /* // Trigger change variant */ #}

    jQueryNuvem(document).on("change", ".js-variation-option", function(e) {
        var $parent = jQueryNuvem(this).closest(".js-product-variants");
        var $variants_group = jQueryNuvem(this).closest(".js-product-variants-group");
        var $quickshop_parent_wrapper = jQueryNuvem(this).closest(".js-quickshop-container");

        {# If quickshop is used from modal, use quickshop-id from the item that opened it #}

        var quick_id = $quickshop_parent_wrapper.attr("data-quickshop-id");

        if($parent.hasClass("js-product-quickshop-variants")){

            var $quickshop_parent = jQueryNuvem(this).closest(".js-item-product");

            {# Target visible slider item if necessary #}
            
            if($quickshop_parent.hasClass("js-item-slide")){
                var $quickshop_variant_selector = '.js-swiper-slide-visible .js-quickshop-container[data-quickshop-id="'+quick_id+'"]';
            }else{
                var $quickshop_variant_selector = '.js-quickshop-container[data-quickshop-id="'+quick_id+'"]';
            }

            LS.changeVariant(changeVariant, $quickshop_variant_selector);

            {% if settings.product_color_variants or settings.bullet_variants %}
                {# Match selected color variant with selected quickshop variant #}

                var selected_option_id = jQueryNuvem(this).val();
                var $color_parent_to_update = jQueryNuvem('.js-quickshop-container[data-quickshop-id="'+quick_id+'"]');

                {# Update all color buttons on several places (quickshop, item, product detail) #}
                $color_parent_to_update.find('.js-color-variant[data-option="'+selected_option_id+'"]').addClass("selected").siblings().removeClass("selected");
                {# Update this specific variant button #}
                $variants_group.find('.js-insta-variant[data-option="'+selected_option_id+'"]').addClass("selected").siblings().removeClass("selected");
            {% endif %}

        } else {
            LS.changeVariant(changeVariant, '#single-product');
        }

        {# Offer and discount labels update #}

        var $this_product_container = jQueryNuvem(this).closest(".js-product-container");

        if($this_product_container.hasClass("js-quickshop-container")){
            var this_quickshop_id = $this_product_container.attr("data-quickshop-id");
            var $this_product_container = jQueryNuvem('.js-product-container[data-quickshop-id="'+this_quickshop_id+'"]');
        }
        var $this_compare_price = $this_product_container.find(".js-compare-price-display");
        var $this_price = $this_product_container.find(".js-price-display");
        var $installment_container = $this_product_container.find(".js-product-payments-container");
        var $installment_text = $this_product_container.find(".js-max-installments-container");
        var $this_add_to_cart = $this_product_container.find(".js-prod-submit-form");

        // Get the current product discount percentage value
        var current_percentage_value = $this_product_container.find(".js-offer-percentage");

        // Get the current product price and promotional price
        var compare_price_value = $this_compare_price.html();
        var price_value = $this_price.html();

        // Calculate new discount percentage based on difference between filtered old and new prices
        const percentageDifference = window.moneyDifferenceCalculator.percentageDifferenceFromString(compare_price_value, price_value);
        if(percentageDifference){
            $this_product_container.find(".js-offer-percentage").text(percentageDifference);
            $this_product_container.find(".js-offer-label").css("display" , "table");
        }

        if ($this_compare_price.css("display") == "none" || !percentageDifference) {
            $this_product_container.find(".js-offer-label").hide();
        }
        if ($this_add_to_cart.hasClass("nostock")) {
            var $stockLabel = $this_product_container.find(".js-stock-label");
            if (!$stockLabel.text().trim()) {
                $stockLabel.text($stockLabel.data('label'));
            }
            $stockLabel.show();
        }
        else {
            $this_product_container.find(".js-stock-label").hide();
	    }
	    if ($this_price.css('display') == 'none'){
	        $installment_container.hide();
	        $installment_text.hide();
	    }else{
	        $installment_text.show();
	    }
	});

	{# /* // Submit to contact */ #}

	{# Submit to contact form when product has no price #}

    jQueryNuvem(".js-product-form").on("submit", function (e) {
	    var button = jQueryNuvem(e.currentTarget).find('[type="submit"]');
	    button.attr('disabled', 'disabled');
	    if ((button.hasClass('contact')) || (button.hasClass('catalog'))) {
	        e.preventDefault();
	        var product_id = jQueryNuvem(e.currentTarget).find("input[name='add_to_cart']").val();
	        window.location = "{{ store.contact_url | escape('js') }}?product=" + product_id;
	    } else if (button.hasClass('cart')) {
	        button.val('{{ "Agregando..." | translate }}');
	    }
	});

    {% set product_detail_with_scrolling_images = template == 'product' and settings.scroll_product_images %}
    {% set home_product_main = template == 'home' ? sections.featured.products %}

    {% set native_videos_enabled = false %}
    {% if template == 'product' and product.hasNativeVideos %}
        {% set native_videos_enabled = true %}
    {% endif %}
    {% if home_product_main %}
        {# on the home, if there is at least one featured product with native videos, we enable them #}
        {% for product in sections.featured.products %}
            {% if product.hasNativeVideos %}
                {% set native_videos_enabled = true %}
            {% endif %}
        {% endfor %}
    {% endif %}

	{% if template == 'product' or home_product_main %}

        {% if native_videos_enabled %}
            var stream_videos = [];
            function initAllVideos(){
                jQueryNuvem(".js-external-video-iframe").each(function($el){
                    const player = Stream(document.getElementById($el.id));
                    stream_videos.push(player);
                });
            }
            initAllVideos();
            function pauseAllVideos(){
                stream_videos.forEach(function(player){
                    player.pause();
                });
            }
            jQueryNuvem(".js-play-native-button").on("click", function($el){
                pauseAllVideos();
                const link = jQueryNuvem(this);
                const id = jQueryNuvem(this).data("video_uid");
                const iframe = jQueryNuvem("#video-" + id);
                const image = jQueryNuvem("img[data-video_uid='" + id + "']");
                const parent = jQueryNuvem(this).parent(".embed-responsive-16by9");
                const container = jQueryNuvem("div[data-video_uid='" + id + "']");
                iframe.attr("src", iframe.data("src"));
                container.show();
                image.hide();
                link.hide().removeClass("d-md-block");
                parent.removeClass("embed-responsive-16by9");
                let allowAttr = iframe.attr("allow");

                if (allowAttr) {
                    allowAttr = allowAttr
                        .split(";")
                        .map(item => item.trim())
                        .filter(item => item && item !== "autoplay")
                        .join("; ");

                    iframe.attr("allow", allowAttr + ";");
                }
            });
        {% endif %}

        var has_multiple_slides = false;

        {% if template == 'product' and (product.media_count > 1 or video_url) %}
            var has_multiple_slides = true;
        {% else %}
            var product_images_amount = jQueryNuvem(".js-swiper-product").attr("data-product-images-amount");
            if(product_images_amount > 1) {
                var has_multiple_slides = true;
            }
        {% endif %}

	    {# /* // Product slider */ #}

        {% if template == 'product' %}
            {% block product_fancybox %}
                Fancybox.bind('[data-fancybox="product-gallery"]', {
                    Toolbar: { 
                        items: {
                            close: {
                                class: 'w-auto px-2 p-md-0',
                                html: '<svg class="icon-inline icon-lg svg-icon-invert"><use xlink:href="#times"/></svg>',
                            },
                            counter: {
                                class: 'mt-2',
                                type: 'div',
                                html: '<span data-fancybox-index=""></span>&nbsp;/&nbsp;<span data-fancybox-count=""></span>',
                                position: 'center',
                            },
                        },
                    },
                    Carousel: {
                        Navigation: {
                            classNames: {
                                button: 'svg-square',
                                next: 'swiper-button-next',
                                prev: 'swiper-button-prev',
                            },
                            prevTpl: '<svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#chevron"/></svg>',
                            nextTpl: '<svg class="icon-inline icon-lg"><use xlink:href="#chevron"/></svg>',
                        },
                    },
                    Thumbs: { autoStart: false },
                        on: {
                            {% if not settings.scroll_product_images %}
                            shouldClose: (fancybox, slide) => {
                                // Update position of the slider
                                productSwiper.slideTo( fancybox.getSlide().index, 0 );
                                jQueryNuvem(".js-product-thumb").removeClass("selected");
                                var $product_thumbnail = jQueryNuvem(".js-product-thumb[data-thumb-loop='"+fancybox.getSlide().index+"']").addClass("selected");
                                if($product_thumbnail.length){
                                    $product_thumbnail.addClass("selected");
                                }else{
                                    jQueryNuvem(".js-product-thumb[data-thumb-loop='4']").addClass("selected");
                                }
                            },
                            {% endif %}
                             {% if native_videos_enabled %}
                                "Carousel.change": (fancybox) => {
                                    pauseAllVideos();
                                },
                            {% endif %}
                        },
                });
            {% endblock %}
        {% endif %}

        function productSliderNav(){
            var width = window.innerWidth;

            var productSwiper = null;
            createSwiper(
                '.js-swiper-product', {
                    lazy: true,
                    effect: 'fade',
                    fadeEffect: {
                        crossFade: true,
                    },
                    {% if has_multiple_slides %}
                    slidesPerView: 1,
                    {% endif %}
                    watchOverflow: true,
                    pagination: {
                        el: '.js-swiper-product-pagination',
                        clickable: true,
                    },
                    navigation: {
                        nextEl: '.js-swiper-product-next',
                        prevEl: '.js-swiper-product-prev',
                    },
                    
                    on: {
                        {% if product.video_url %}
                            init: function () {
                                if (window.innerWidth < 768) {
                                    productSwiperHeight = jQueryNuvem(".js-swiper-product").height();
                                    jQueryNuvem(".js-product-video-slide").height(productSwiperHeight);
                                }
                            },
                            slideChangeTransitionEnd: function () {
                                const $parent = jQueryNuvem(this.el).closest(".js-product-detail");
                                const $labelsFloatingGroup = $parent.find(".js-labels-floating-group");
                                if(jQueryNuvem(".js-product-video-slide").hasClass("swiper-slide-active")){
                                    $labelsFloatingGroup.fadeOut(100);
                                }else{
                                    $labelsFloatingGroup.fadeIn(100);
                                }
                                jQueryNuvem('.js-video').show();
                                jQueryNuvem('.js-video-iframe').hide().find("iframe").remove();
                            },
                        {% endif %}
                        {% if native_videos_enabled %}
                            slideChange : function () {
                                pauseAllVideos();
                            },
                        {% endif %}
                    },
                },
                function(swiperInstance) {
                    productSwiper = swiperInstance;
                }
            );

            {% if template == 'product' %}
                {{ block ('product_fancybox') }}
            {% endif %}

            if(has_multiple_slides){
                LS.registerOnChangeVariant(function(variant){
                    var liImage = jQueryNuvem('.js-swiper-product').find("[data-image='"+variant.image+"']");
                    var selectedPosition = liImage.data('imagePosition');
                    var slideToGo = parseInt(selectedPosition);
                    productSwiper.slideTo(slideToGo);
                    jQueryNuvem(".js-product-slide-img").removeClass("js-active-variant");
                    liImage.find(".js-product-slide-img").addClass("js-active-variant");
                });

                jQueryNuvem(".js-product-thumb").on("click", function(e){
                    e.preventDefault();
                    jQueryNuvem(".js-product-thumb").removeClass("selected");
                    jQueryNuvem(e.currentTarget).addClass("selected");
                    var thumbLoop = jQueryNuvem(e.currentTarget).data("thumbLoop");
                    var slideToGo = parseInt(thumbLoop);
                    productSwiper.slideTo(slideToGo);
                    if(jQueryNuvem(e.currentTarget).hasClass("js-product-thumb-modal")){
                        var video_id = jQueryNuvem(e.currentTarget).data("video_id");
                        if(video_id){
                            jQueryNuvem('#trigger-video-modal-' + video_id).trigger('click');
                            return;
                        }
                        jQueryNuvem('.js-swiper-product').find("[data-image-position='"+slideToGo+"'] .js-product-slide-link").trigger('click');
                    }
                });
            }
        }

        {% if product_detail_with_scrolling_images or home_product_main %}
            {% if product_detail_with_scrolling_images %}
            if ( window.innerWidth < 768 ) {
            {% endif %}
                productSliderNav ()
            {% if product_detail_with_scrolling_images %}
            } else {
            {% endif %}
                jQueryNuvem(".js-sticky-product").css("top" , (head_height + 10).toString() + 'px');

                {% if product_detail_with_scrolling_images %}

                    {{ block ('product_fancybox') }}

                    LS.registerOnChangeVariant(function(variant){
                        var liImage = jQueryNuvem('.js-swiper-product').find("[data-image='"+variant.image+"']");
                        var selectedScroll = liImage.position.top;
                        document.documentElement.scroll({
                            top: jQueryNuvem(liImage).offset().top,
                            behavior: 'smooth'
                        });
                    });

                    window.addEventListener("resize", function() {
                        if ( window.innerWidth < 768 ) {
                            productSliderNav()
                        }
                    });
                {% endif %}
            {% if product_detail_with_scrolling_images %}
            }
            {% endif %}
        {% else %}
            productSliderNav()
        {% endif %}

        {# /* // Pinterest sharing */ #}

        jQueryNuvem('.js-pinterest-share').on("click", function(e){
            e.preventDefault();
            jQueryNuvem(".pinterest-hidden a").get()[0].click();
        });

        {# Product show description and relocate on mobile #}

        if (window.innerWidth > 767) {
            jQueryNuvem("#product-description").show();
        }else{
            jQueryNuvem("#product-description").insertAfter("#product_form").show();
        }

	{% endif %}

    {% if home_product_main %}

        {# /* // Product thumbs swiper */ #}

        createSwiper('.js-swiper-product-thumbs', {
            lazy: true,
            watchOverflow: true,
            threshold: 5,
            direction: 'vertical',
            navigation: {
                nextEl: '.js-swiper-product-thumbs-next',
                prevEl: '.js-swiper-product-thumbs-prev',
            },
            slidesPerView: 'auto',
            on: {
                afterInit: function () {
                    hideSwiperControls(".js-swiper-product-thumbs-prev", ".js-swiper-product-thumbs-next");
                },
            },
        });

        {# /* // Product description toggle */ #}

        if (jQueryNuvem('.js-product-description').height() < jQueryNuvem('.js-product-description').prop("scrollHeight")){
            jQueryNuvem(".js-view-description").show();
        }

        jQueryNuvem(document).on("click", ".js-view-description", function(e) {
            e.preventDefault();
            jQueryNuvem(this).prev(".js-product-description").toggleClass("home-product-description-full");
            jQueryNuvem(".js-view-more, .js-view-less").toggle();
        });
    {% endif %}

    {# Product quantitiy #}

    jQueryNuvem(document).on("click", ".js-quantity .js-quantity-up", function (e) {
        $quantity_input = jQueryNuvem(this).closest(".js-quantity").find(".js-quantity-input");
        $quantity_input.val( parseInt($quantity_input.val(), 10) + 1);
    });

    jQueryNuvem(document).on("click", ".js-quantity .js-quantity-down", function (e) {
        $quantity_input = jQueryNuvem(this).closest(".js-quantity").find(".js-quantity-input");
        quantity_input_val = $quantity_input.val();
        if (quantity_input_val>1) {
            $quantity_input.val( parseInt($quantity_input.val(), 10) - 1);
        }
    });


	{#/*============================================================================
	  #Cart
	==============================================================================*/ #}

    {% if cart.free_shipping.min_price_free_shipping.min_price %}

        {# Updates free progress on page load #}

        LS.freeShippingProgress(true);

    {% endif %}

    {# /* // Position of cart page summary */ #}

    var head_height = jQueryNuvem(".js-head-main").outerHeight();

    if (window.innerWidth > 768) {
        {% if settings.head_fix_desktop %}
            jQueryNuvem("#cart-sticky-summary").css("top" , (head_height + 10).toString() + 'px');
        {% else %}
            jQueryNuvem("#cart-sticky-summary").css("top" , "10px");
        {% endif %}
    }


    {# /* // Add to cart */ #}

    function getQuickShopImgSrc(element){
        const image = jQueryNuvem(element).closest('.js-quickshop-container').find('img');
        return String(image.attr('srcset')); 
    }

    jQueryNuvem(document).on("click", ".js-addtocart:not(.js-addtocart-placeholder)", function (e) {

        {# Button variables for transitions on add to cart #}

        var $productContainer = jQueryNuvem(this).closest('.js-product-container');
        var $productVariants = $productContainer.find(".js-variation-option");
        var $productButton = $productContainer.find("input[type='submit'].js-addtocart");
        var $productButtonPlaceholder = $productContainer.find(".js-addtocart-placeholder");
        var $productButtonText = $productButtonPlaceholder.find(".js-addtocart-text");
        var $productButtonAdding = $productButtonPlaceholder.find(".js-addtocart-adding");
        var $productButtonSuccess = $productButtonPlaceholder.find(".js-addtocart-success");

        {# Define if event comes from quickshop, product page or cross selling #}

        var isQuickShop = $productContainer.hasClass('js-quickshop-container');
        if (isQuickShop) {
            var $productButtonContainer = $productButton.closest(".js-item-submit-container");
        }
        var isCrossSelling = $productContainer.hasClass('js-cross-selling-container');

         {# Added item information for notification #}

        if (isCrossSelling) {
            var imageSrc = $productContainer.find('.js-cross-selling-product-image').attr('src');
            var quantity = $productContainer.data('quantity')
            var name = $productContainer.find('.js-cross-selling-product-name').text();
            var price = $productContainer.find('.js-cross-selling-promo-price').text();
            var addedToCartCopy = $productContainer.data('add-to-cart-translation');
        } else if (!isQuickShop) {
            if(jQueryNuvem(".js-product-slide-img.js-active-variant").length) {
                var $activeVariantImg = $productContainer.find('.js-product-slide-img.js-active-variant');
                var imageSrc = $activeVariantImg.attr('srcset') || $activeVariantImg.data('srcset');
            } else {
                var $defaultImg = $productContainer.find('.js-product-slide-img');
                var imageSrc = $defaultImg.attr('srcset') || $defaultImg.data('srcset');
            }

            imageSrc = imageSrc ? imageSrc.split(' ')[0] : '';
            var quantity = $productContainer.find('.js-quantity-input').val();
            var name = $productContainer.find('.js-product-name').text();
            var price = $productContainer.find('.js-price-display').text();
            var addedToCartCopy = "{{ 'Agregar al carrito' | translate }}";
        } else {
            var imageSrc = getQuickShopImgSrc(this);
            var quantity = 1;
            var name = $productContainer.find('.js-item-name').text();
            var price = $productContainer.find('.js-price-display').text().trim();
            var addedToCartCopy = "{{ 'Comprar' | translate }}";
            if ($productContainer.hasClass("js-quickshop-has-variants")) {
                var addedToCartCopy = "{{ 'Agregar al carrito' | translate }}";
            }else{
                var addedToCartCopy = "{{ 'Comprar' | translate }}";
            }
        }

        if (!jQueryNuvem(this).hasClass('contact')) {

            {% if settings.ajax_cart %}
                e.preventDefault();
            {% endif %}

            {# Hide real button and show button placeholder during event #}

            $productButton.hide();
            if (isQuickShop) {
                $productButtonContainer.hide();
            }
            $productButtonPlaceholder.css('display' , 'inline-block');
            $productButtonText.fadeOut();
            $productButtonAdding.addClass("active");

            {# Restore button state in case of error #}

            function restore_button_initial_state(){
                $productButtonAdding.removeClass("active");
                $productButtonText.fadeIn();
                $productButtonPlaceholder.removeAttr("style").hide();
                $productButton.show();
                if (isQuickShop) {
                    $productButtonContainer.show();
                }
            }

            {# Restore button state for subscriptions stock error #}

            var subscription_callback_error = function() {
                setTimeout(function() {
                    restore_button_initial_state();
                }, 500);
            }

            {# Handle subscribable product submit #}

            LS.subscriptionSubmit($productContainer, subscription_callback_error, e);

            {% if settings.ajax_cart %}

                var callback_add_to_cart = function(html_notification_related_products, html_notification_cross_selling) {

                    {# Fill notification info #}

                    jQueryNuvem('.js-cart-notification-item-img').attr('srcset', imageSrc);
                    jQueryNuvem('.js-cart-notification-item-name').text(name);
                    jQueryNuvem('.js-cart-notification-item-quantity').text(quantity);
                    jQueryNuvem('.js-cart-notification-item-price').text(price);

                    LS.updateNotificationDiscountLabel($productContainer[0]);

                    if($productVariants.length){
                        var output = [];

                        $productVariants.each( function(el){
                            var variants = jQueryNuvem(el);
                            output.push(variants.val());
                        });
                        jQueryNuvem(".js-cart-notification-item-variant-container").show();
                        jQueryNuvem(".js-cart-notification-item-variant").text(output.join(', '))
                    }else{
                        jQueryNuvem(".js-cart-notification-item-variant-container").hide();
                    }

                    {# Set products amount wording visibility #}

                    var cartItemsAmount = jQueryNuvem(".js-cart-widget-amount").text();

                    if(cartItemsAmount > 1){
                        jQueryNuvem(".js-cart-counts-plural").show();
                        jQueryNuvem(".js-cart-counts-singular").hide();
                    }else{
                        jQueryNuvem(".js-cart-counts-singular").show();
                        jQueryNuvem(".js-cart-counts-plural").hide();
                    }

                    {# Show button placeholder with transitions #}

                    $productButtonAdding.removeClass("active");
                    $productButtonSuccess.addClass("active");
                    setTimeout(function(){
                        $productButtonSuccess.removeClass("active");
                        $productButtonText.fadeIn();
                    },2000);
                    setTimeout(function(){
                        $productButtonPlaceholder.removeAttr("style").hide();
                        $productButton.show();
                        if (isQuickShop) {
                            $productButtonContainer.show();
                        }
                    },3000);

                    $productContainer.find(".js-added-to-cart-product-message").slideDown();

                    if (isQuickShop) {
                        jQueryNuvem("#quickshop-modal").removeClass('modal-show');
                        jQueryNuvem(".js-modal-overlay[data-modal-id='#quickshop-modal']").hide();
                        jQueryNuvem("body").removeClass("overflow-none");
                        restoreQuickshopForm();
                        if (window.innerWidth < 768) {
                            cleanURLHash();
                        }
                    }

                    let notificationWithRelatedProducts = false;

                    {% if settings.add_to_cart_recommendations %}

                        {# Show added to cart product related products #}

                        function recommendProductsOnAddToCart(){

                            jQueryNuvem('.js-related-products-notification-container').html("");

                            modalOpen('#related-products-notification');

                            jQueryNuvem('.js-related-products-notification-container').html(html_notification_related_products).show();

                            {# Recommendations swiper #}

                            // Set loop for recommended products

                            function calculateRelatedNotificationLoopVal(sectionSelector) {
                                let productsAmount = jQueryNuvem(sectionSelector).attr("data-related-amount");
                                let loopVal = false;
                                const applyLoop = (window.innerWidth < 768 && productsAmount > 2.5) || (window.innerWidth > 768 && productsAmount > 3);
                                
                                if (applyLoop) {
                                    loopVal = true;
                                }
                                
                                return loopVal;
                            }

                            let cartRelatedLoopVal = calculateRelatedNotificationLoopVal(".js-related-products-notification");

                            // Create new swiper on add to cart

                            createSwiper('.js-swiper-related-products-notification', {
                                lazy: true,
                                loop: cartRelatedLoopVal,
                                watchOverflow: true,
                                threshold: 5,
                                watchSlideProgress: true,
                                watchSlidesVisibility: true,
                                spaceBetween: itemSwiperSpaceBetween,
                                slideVisibleClass: 'js-swiper-slide-visible',
                                slidesPerView: 2.5,
                                navigation: {
                                    nextEl: '.js-swiper-related-products-notification-next',
                                    prevEl: '.js-swiper-related-products-notification-prev',
                                },
                                breakpoints: {
                                    768: {
                                        slidesPerView: 3,
                                    }
                                }
                            });
                        }
                        
                        notificationWithRelatedProducts = html_notification_related_products != null;

                        if(notificationWithRelatedProducts){
                            if (isQuickShop) {
                                setTimeout(function(){
                                    recommendProductsOnAddToCart();
                                },300);
                            }else{
                                recommendProductsOnAddToCart();
                            }
                        }

                    {% endif %}

                    let shouldShowCrossSellingModal = html_notification_cross_selling != null;

                    if(!notificationWithRelatedProducts){

                        const cartOpenType = jQueryNuvem("#modal-cart").attr('data-cart-open-type');

                        if((cartOpenType === 'show_cart') && !shouldShowCrossSellingModal){

                            {# Open cart on add to cart #}

                            modalOpen('#modal-cart');

                        }else{

                            {# Show notification and hide it only after second added to cart #}

                            setTimeout(function(){
                                jQueryNuvem(".js-alert-added-to-cart").show().addClass("notification-visible").removeClass("notification-hidden");
                            },500);

                            if (!cookieService.get('first_product_added_successfully')) {
                                cookieService.set('first_product_added_successfully', 1, 7 );
                            } else{
                                setTimeout(function(){
                                    jQueryNuvem(".js-alert-added-to-cart").removeClass("notification-visible").addClass("notification-hidden");
                                    setTimeout(function(){
                                        jQueryNuvem('.js-cart-notification-item-img').attr('src', '');
                                        jQueryNuvem(".js-alert-added-to-cart").hide();
                                    },2000);
                                },8000);
                            }
                        }
                    }

                    {# Display cross-selling promotion modal #}

                    if (html_notification_cross_selling != null) {
                        jQueryNuvem('.js-cross-selling-modal-body').html("");
                        modalOpen('#js-cross-selling-modal');
                        jQueryNuvem('.js-cross-selling-modal-body').html(html_notification_cross_selling).show();
                    }

                    {# Change prices on cross-selling promotion modal #}

                    const crossSellingContainer = document.querySelector('.js-cross-selling-container');

                    if (crossSellingContainer) {
                        LS.fillCrossSelling(crossSellingContainer);
                    }

                    {# Update shipping input zipcode on add to cart #}

                    {# Use zipcode from input if user is in product page, or use zipcode cookie if is not #}

                    if (jQueryNuvem("#product-shipping-container .js-shipping-input").val()) {
                        zipcode_on_addtocart = jQueryNuvem("#product-shipping-container .js-shipping-input").val();
                        jQueryNuvem("#cart-shipping-container .js-shipping-input").val(zipcode_on_addtocart);
                        jQueryNuvem(".js-shipping-calculator-current-zip").text(zipcode_on_addtocart);
                    } else if (cookieService.get('calculator_zipcode')){
                        var zipcode_from_cookie = cookieService.get('calculator_zipcode');
                        jQueryNuvem('.js-shipping-input').val(zipcode_from_cookie);
                        jQueryNuvem(".js-shipping-calculator-current-zip").text(zipcode_from_cookie);
                    }

                    {# Update free shipping wording #}

                    jQueryNuvem(".js-fs-add-this-product").hide();
                    jQueryNuvem(".js-fs-add-one-more").show();

                    {# Automatically close the cross-selling modal by triggering its close button #}

                    if (isCrossSelling) {
                        jQueryNuvem('#js-cross-selling-modal .js-modal-close').trigger('click');
                    }
                }
                var callback_error = function(){
                    {# Restore real button visibility in case of error #}
                    restore_button_initial_state();
                }
                $prod_form = jQueryNuvem(this).closest("form");
                LS.addToCartEnhanced(
                    $prod_form,
                    addedToCartCopy,
                    '{{ "Agregando..." | translate }}',
                    '{{ "¡Uy! No tenemos más stock de este producto para agregarlo al carrito." | translate }}',
                    {{ store.editable_ajax_cart_enabled ? 'true' : 'false' }},
                        callback_add_to_cart,
                        callback_error
                );
            {% endif %}
        }
    });


    {# /* // Cart quantitiy changes */ #}

    jQueryNuvem(document).on("keypress", ".js-cart-quantity-input", function (e) {
        if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)) {
            return false;
        }
    });

    jQueryNuvem(document).on("focusout", ".js-cart-quantity-input", function (e) {
        var itemID = jQueryNuvem(this).attr("data-item-id");
        var itemVAL = jQueryNuvem(this).val();
        if (itemVAL == 0) {
            var r = confirm("{{ '¿Seguro que quieres borrar este artículo?' | translate }}");
            if (r == true) {
                LS.removeItem(itemID, true);
            } else {
                jQueryNuvem(this).val(1);
            }
        } else {
            LS.changeQuantity(itemID, itemVAL, true);
        }
    });

    {# /* // Empty cart alert */ #}

    jQueryNuvem(".js-trigger-empty-cart-alert").on("click", function (e) {
        e.preventDefault();
        let emptyCartAlert = jQueryNuvem(".js-mobile-nav-empty-cart-alert").fadeIn(100);
        setTimeout(() => emptyCartAlert.fadeOut(500), 1500);
    });

    {# /* // Go to checkout */ #}

    {# Clear cart notification cookie after consumers continues to checkout #}

    jQueryNuvem('form[action="{{ store.cart_url | escape('js') }}"]').on("submit", function() {
        cookieService.remove('first_product_added_successfully');
    });


	{#/*============================================================================
	  #Shipping calculator
	==============================================================================*/ #}

    {# /* // Update calculated cost wording */ #}

    {% if settings.shipping_calculator_cart_page %}
        if (jQueryNuvem('.js-selected-shipping-method').length) {
            LS.ShippingDiscountRow.apply(jQueryNuvem('.js-selected-shipping-method')[0], {});
            jQueryNuvem("#shipping-cost").removeClass('opacity-40');
        }
    {% endif %}

	{# /* // Select and save shipping function */ #}

    selectShippingOption = function(elem, save_option) {
        jQueryNuvem(".js-shipping-method, .js-branch-method").removeClass('js-selected-shipping-method');
        jQueryNuvem(elem).addClass('js-selected-shipping-method');

        {% if settings.shipping_calculator_cart_page %}

            LS.ShippingDiscountRow.apply(elem, {});
            jQueryNuvem("#shipping-cost").removeClass('opacity-40');

        {% endif %}

        if (save_option) {
            LS.saveCalculatedShipping(true);
        }
        if (jQueryNuvem(elem).hasClass("js-shipping-method-hidden")) {
            {# Toggle other options visibility depending if they are pickup or delivery for cart and product at the same time #}
            if (jQueryNuvem(elem).hasClass("js-pickup-option")) {
                jQueryNuvem(".js-other-pickup-options, .js-show-other-pickup-options .js-shipping-see-less").show();
                jQueryNuvem(".js-show-other-pickup-options .js-shipping-see-more").hide();
            } else {
                jQueryNuvem(".js-other-shipping-options, .js-show-more-shipping-options .js-shipping-see-less").show();
                jQueryNuvem(".js-show-more-shipping-options .js-shipping-see-more").hide()
            }
        }
    };

    {# Apply zipcode saved by cookie if there is no zipcode saved on cart from backend #}

    if (cookieService.get('calculator_zipcode')) {

        {# If there is a cookie saved based on previous calcualtion, add it to the shipping input to triggert automatic calculation #}

        var zipcode_from_cookie = cookieService.get('calculator_zipcode');

        {% if settings.ajax_cart %}

            {# If ajax cart is active, target only product input to avoid extra calulation on empty cart #}

            jQueryNuvem('#product-shipping-container .js-shipping-input').val(zipcode_from_cookie);

        {% else %}

            {# If ajax cart is inactive, target the only input present on screen #}

            jQueryNuvem('.js-shipping-input').val(zipcode_from_cookie);

        {% endif %}

        jQueryNuvem(".js-shipping-calculator-current-zip").text(zipcode_from_cookie);

        {# Hide the shipping calculator and show spinner  #}

        jQueryNuvem(".js-shipping-calculator-head").addClass("with-zip").removeClass("with-form");
        jQueryNuvem(".js-shipping-calculator-with-zipcode").addClass("transition-up-active");
        jQueryNuvem(".js-shipping-calculator-spinner").show();
    } else {

        {# If there is no cookie saved, show calcualtor #}

        jQueryNuvem(".js-shipping-calculator-form").addClass("transition-up-active");
    }

    {# Remove shipping suboptions from DOM to avoid duplicated modals #}

    removeShippingSuboptions = function(){
        var shipping_suboptions_id = jQueryNuvem(".js-modal-shipping-suboptions").attr("id");
        jQueryNuvem("#" + shipping_suboptions_id).remove();
        jQueryNuvem('.js-modal-overlay[data-modal-id="#' + shipping_suboptions_id + '"').remove();
    };

    {# /* // Calculate shipping function */ #}


    jQueryNuvem(".js-calculate-shipping").on("click", function (e) {
	    e.preventDefault();

        {# Take the Zip code to all shipping calculators on screen #}
        let shipping_input_val = jQueryNuvem(e.currentTarget).closest(".js-shipping-calculator-form").find(".js-shipping-input").val();

        jQueryNuvem(".js-shipping-input").val(shipping_input_val);

        {# Calculate on page load for both calculators: Product and Cart #}

        if (jQueryNuvem(".js-cart-item").length) {
            LS.calculateShippingAjax(
            jQueryNuvem('#cart-shipping-container').find(".js-shipping-input").val(),
            '{{store.shipping_calculator_url | escape('js')}}',
            jQueryNuvem("#cart-shipping-container").closest(".js-shipping-calculator-container") );
        }

        jQueryNuvem(".js-shipping-calculator-current-zip").html(shipping_input_val);
        removeShippingSuboptions();
	});

	{# /* // Calculate shipping by submit */ #}

    jQueryNuvem(".js-shipping-input").on('keydown', function (e) {
	    var key = e.which ? e.which : e.keyCode;
	    var enterKey = 13;
	    if (key === enterKey) {
	        e.preventDefault();
            jQueryNuvem(e.currentTarget).closest(".js-shipping-calculator-form").find(".js-calculate-shipping").trigger('click');
	        if (window.innerWidth < 768) {
                jQueryNuvem(e.currentTarget).trigger('blur');
	        }
	    }
	});

    {# /* // Shipping and branch click */ #}

    jQueryNuvem(document).on("change", ".js-shipping-method, .js-branch-method", function (e) {
        selectShippingOption(this, true);
        jQueryNuvem(".js-shipping-method-unavailable").hide();
    });

    {# /* // Select shipping first option on results */ #}

    jQueryNuvem(document).on('shipping.options.checked', '.js-shipping-method', function (e) {
        let shippingPrice = jQueryNuvem(this).attr("data-price");
        LS.addToTotal(shippingPrice);

        let total = (LS.data.cart.total / 100) + parseFloat(shippingPrice);
        jQueryNuvem(".js-cart-widget-total").html(LS.formatToCurrency(total));

        selectShippingOption(this, false);
    });

    {# /* // Toggle more shipping options */ #}

    jQueryNuvem(document).on("click", ".js-toggle-more-shipping-options", function(e) {
	    e.preventDefault();

        {# Toggle other options depending if they are pickup or delivery for cart and product at the same time #}

        if(jQueryNuvem(this).hasClass("js-show-other-pickup-options")){
            jQueryNuvem(".js-other-pickup-options").slideToggle(600);
            jQueryNuvem(".js-show-other-pickup-options .js-shipping-see-less, .js-show-other-pickup-options .js-shipping-see-more").toggle();
        }else{
            jQueryNuvem(".js-other-shipping-options").slideToggle(600);
            jQueryNuvem(".js-show-more-shipping-options .js-shipping-see-less, .js-show-more-shipping-options .js-shipping-see-more").toggle();
        }
	});

    {# /* // Calculate shipping on page load */ #}

    {# Only shipping input has value, cart has saved shipping and there is no branch selected #}

    calculateCartShippingOnLoad = function() {
        {# Triggers function when a zipcode input is filled #}
        if (jQueryNuvem("#cart-shipping-container .js-shipping-input").val()) {
            // If user already had calculated shipping: recalculate shipping
            setTimeout(function() {
                LS.calculateShippingAjax(
                    jQueryNuvem('#cart-shipping-container').find(".js-shipping-input").val(),
                    '{{store.shipping_calculator_url | escape('js')}}',
                    jQueryNuvem("#cart-shipping-container").closest(".js-shipping-calculator-container") );
                removeShippingSuboptions();
                toggleAccordion("#cart-shipping-container .js-toggle-shipping");
            }, 100);
        }

        if (jQueryNuvem(".js-branch-method").hasClass('js-selected-shipping-method')) {
            {% if store.branches|length > 1 %}
                toggleAccordion("#cart-shipping-container .js-toggle-branches");
            {% endif %}
        }
    };

    {% if cart.has_shippable_products %}
        calculateCartShippingOnLoad();
    {% endif %}

    {# /* // Change CP */ #}

    jQueryNuvem(document).on("click", ".js-shipping-calculator-change-zipcode", function(e) {
        e.preventDefault();
        jQueryNuvem(".js-shipping-calculator-response").fadeOut(100);
        jQueryNuvem(".js-shipping-calculator-head").addClass("with-form").removeClass("with-zip");
        jQueryNuvem(".js-shipping-calculator-with-zipcode").removeClass("transition-up-active");
        jQueryNuvem(".js-shipping-calculator-form").addClass("transition-up-active");
    });

	{# /* // Shipping provinces */ #}

	{% if provinces_json %}
        jQueryNuvem('select[name="country"]').on("change", function (e) {
		    var provinces = {{ provinces_json | default('{}') | raw }};
		    LS.swapProvinces(provinces[jQueryNuvem(e.currentTarget).val()]);
		}).trigger('change');
	{% endif %}


    {# /* // Change store country: From invalid zipcode message */ #}

    jQueryNuvem(document).on("click", ".js-save-shipping-country", function(e) {

        e.preventDefault();

        {# Change shipping country #}

        lang_select_option = jQueryNuvem(this).closest(".js-modal-shipping-country");
        changeLang(lang_select_option);

        jQueryNuvem(this).text('{{ "Aplicando..." | translate }}').addClass("disabled");
    });

    {#/*============================================================================
      #Forms
    ==============================================================================*/ #}

    {# IOS form CSS to avoid autozoom on focus #}

    var isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
    if (isIOS) {
        var ios_input_fields = jQueryNuvem("input[type='text'], input[type='number'], input[type='password'], input[type='tel'], textarea, input[type='search'], input[type='hidden'], input[type='email']");
        ios_input_fields.addClass("form-control-ios");
        jQueryNuvem(".js-quantity").addClass("form-group-quantity-ios");
        jQueryNuvem(".js-cart-quantity-container").addClass("cart-quantity-container-ios");
        jQueryNuvem(".js-price-filter-btn").addClass("price-btn-ios");
        jQueryNuvem(".js-price-filter-empty").addClass("input-clear-content-ios");
        jQueryNuvem(".js-newsletter, .js-news-form").addClass("form-group-newsletter-ios");
    }

    jQueryNuvem(".js-winnie-pooh-form").on("submit", function (e) {
        jQueryNuvem(e.currentTarget).attr('action', '');
    });

    jQueryNuvem(".js-form").on("submit", function (e) {
        jQueryNuvem(e.currentTarget).find('.js-form-spinner').show();
    });

    {% if template == 'account.login' %}
        {% if result.invalid %}
            jQueryNuvem(".js-account-input").addClass("alert-danger");
            jQueryNuvem(".js-account-input.alert-danger").on("focus", function() {
                jQueryNuvem(".js-account-input").removeClass("alert-danger");
            });
        {% endif %}
    {% endif %}

    {# Show the success or error message when resending the validation link #}

    {% if template == 'account.register' or template == 'account.login' %}
        jQueryNuvem(".js-resend-validation-link").on("click", function(e){
            window.accountVerificationService.resendVerificationEmail('{{ customer_email }}');
        });
    {% endif %}

    jQueryNuvem('.js-password-view').on("click", function (e) {
        jQueryNuvem(e.currentTarget).toggleClass('password-view');

        if(jQueryNuvem(e.currentTarget).hasClass('password-view')){
            jQueryNuvem(e.currentTarget).parent().find(".js-password-input").attr('type', '');
            jQueryNuvem(e.currentTarget).find(".js-eye-open, .js-eye-closed").toggle();
        } else {
            jQueryNuvem(e.currentTarget).parent().find(".js-password-input").attr('type', 'password');
            jQueryNuvem(e.currentTarget).find(".js-eye-open, .js-eye-closed").toggle();
        }
    });


    {#/*============================================================================
      #Footer
    ==============================================================================*/ #}

    {% if store.afip %}

        {# Add alt attribute to external AFIP logo to improve SEO #}

        jQueryNuvem('img[src*="www.afip.gob.ar"]').attr('alt', '{{ "Logo de AFIP" | translate }}');

    {% endif %}


    {#/*============================================================================
      #Empty placeholders
    ==============================================================================*/ #}

    {% set show_help = not has_products %}

    {% if template == 'home' and show_help %}

        {# /* // Home slider */ #}

        var width = window.innerWidth;
        if (width > 767) {
            var slider_empty_autoplay = {delay: 6000,};
        } else {
            var slider_empty_autoplay = false;
        }

        window.homeEmptySlider = {
            getAutoRotation: function() {
                return slider_empty_autoplay;
            },
        };
        createSwiper('.js-home-empty-slider', {
            {% if not params.preview %}
            lazy: true,
            {% endif %}
            loop: true,
            autoplay: slider_empty_autoplay,
            pagination: {
                el: '.js-swiper-empty-home-pagination',
                clickable: true,
            },
            navigation: {
                nextEl: '.js-swiper-empty-home-next',
                prevEl: '.js-swiper-empty-home-prev',
            },
            on: {
                init: function () {
                    jQueryNuvem(".js-home-empty-slider").css("visibility", "visible").css("height", "100%");
                },
            },
        });


        {# /* // Banner services slider */ #}
        var width = window.innerWidth;
        if (width < 767) {
            createSwiper('.js-informative-banners', {
                slidesPerView: 1,
                watchOverflow: true,
                centerInsufficientSlides: true,
                pagination: {
                    el: '.js-informative-banners-pagination',
                    clickable: true,
                },
                breakpoints: {
                    640: {
                        slidesPerView: 3,
                    }
                }
            });
        }

    {% endif %}

    {% if template == '404' or template == 'home' %}

        {# /* // Product slider */ #}

        createSwiper('.js-swiper-product-demo', {
            lazy: true,
            loop: true,
            centeredSlides: true,
            effect: 'fade',
            fadeEffect: {
                crossFade: true,
            },
            pagination: {
                el: '.js-swiper-product-pagination-demo',
                clickable: true,
            },
        });

        createSwiper('.js-swiper-product-thumbs-demo', {
            lazy: true,
            watchOverflow: true,
            threshold: 5,
            direction: 'vertical',
            navigation: {
                nextEl: '.js-swiper-product-thumbs-next-demo',
                prevEl: '.js-swiper-product-thumbs-prev-demo',
            },
            slidesPerView: 'auto',
        });

    {% endif %}

    {% if template == '404' %}

        {# /* // Product Related */ #}

        createSwiper('.js-swiper-related-demo', {
            lazy: true,
            loop: true,
            watchOverflow: true,
            centerInsufficientSlides: true,
            spaceBetween: itemSwiperSpaceBetween,
            slidesPerView: slidesPerViewMobileVal,
            watchSlideProgress: true,
            watchSlidesVisibility: true,
            slideVisibleClass: 'js-swiper-slide-visible',
            navigation: {
                nextEl: '.js-swiper-related-next-demo',
                prevEl: '.js-swiper-related-prev-demo',
            },
            breakpoints: {
                640: {
                    slidesPerView: slidesPerViewDesktopVal,
                }
            }
        });

        {# /* 404 handling to show the example product */ #}

        if (/\/product\/example\/?$/.test(window.location.pathname)) {
            document.title = "{{ "Producto de ejemplo" | translate | escape('js') }}";
            jQueryNuvem("#page-error").hide();
            jQueryNuvem("#product-example").show();
        } else {
            jQueryNuvem("#product-example").hide();
        }

    {% endif %}

});