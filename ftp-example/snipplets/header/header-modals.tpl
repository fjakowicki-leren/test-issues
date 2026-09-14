{# Modal Hamburger #}

{% set modal_position_desktop_val = 'left' %}
{% if settings.logo_position_desktop != 'center' %}
	{% set modal_position_desktop_val = 'right' %}
{% endif %}

{% set modal_position_mobile_val = 'left' %}
{% if settings.show_tab_nav %}
	{% set modal_position_mobile_val = 'bottom' %}
{% elseif settings.logo_position_mobile != 'center' %}
	{% set modal_position_mobile_val = 'right' %}
{% endif %}

{% set modal_with_desktop_only_overlay_val = false %}
{% set modal_mobile_full_screen_val = true %}
{% set tabnav_modal_classes = '' %}
{% if settings.show_tab_nav %}
	{% set modal_with_desktop_only_overlay_val = true %}
	{% set modal_mobile_full_screen_val = false %}
	{% set tabnav_modal_classes = 'js-tabnav-modal tabnav-modal' %}
{% endif %}

{% embed "snipplets/modal.tpl" with{modal_id: 'nav-hamburger',modal_class: 'nav-hamburger modal-docked-md pb-0 ' ~ tabnav_modal_classes, modal_position: modal_position_mobile_val, modal_position_desktop: modal_position_desktop_val, modal_transition: 'slide', modal_width: 'full', modal_mobile_full_screen: false, modal_hide_close: 'true',modal_body_class: 'nav-body', modal_footer_class: 'pb-0 pt-3', modal_fixed_footer: true, modal_footer: true, desktop_overlay_only: modal_with_desktop_only_overlay_val} %}
	{% block modal_body %}
		{% include "snipplets/navigation/navigation-panel.tpl" with {hamburger: true, primary_links: true} %}
	{% endblock %}
{% endembed %}

{# Notifications #}

{# Modal Search #}

{% set modal_position_desktop_val = 'left' %}
{% if settings.logo_position_desktop != 'center' %}
	{% set modal_position_desktop_val = 'right' %}
{% endif %}

{% embed "snipplets/modal.tpl" with{modal_id: 'nav-search',modal_class: 'nav-search ' ~ tabnav_modal_classes, modal_position: modal_position_mobile_val, modal_position_desktop: modal_position_desktop_val, modal_transition: 'slide', modal_width: 'docked-md', modal_header_title: false, desktop_overlay_only: modal_with_desktop_only_overlay_val } %}
	{% block modal_body %}
		{% include "snipplets/header/header-search.tpl" with {use_big_search: true} %}
	{% endblock %}
{% endembed %}


{# Modal Cart #}

{% if settings.show_tab_nav %}
	{% set modal_cart_position_mobile_val = 'bottom' %}
{% else %}
	{% set modal_cart_position_mobile_val = 'right' %}
{% endif %}

{% if not store.is_catalog and settings.ajax_cart and template != 'cart' %}           

	{# Cart Ajax #}

	{% embed "snipplets/modal.tpl" with{
		modal_id: 'modal-cart',
		modal_class: 'cart ' ~ tabnav_modal_classes, 
		modal_position: modal_cart_position_mobile_val, 
		modal_position_desktop: 'right', 
		modal_transition: 'slide', 
		modal_width: 'docked-md', 
		modal_form_action: store.cart_url, 
		modal_form_class: 'js-ajax-cart-panel', 
		modal_header_title: true,
		modal_header_align: 'left',
		modal_mobile_full_screen: modal_mobile_full_screen_val, 
		modal_form_hook: 'cart-form', 
		data_component:'cart',
		custom_data_attribute: 'cart-open-type',
		custom_data_attribute_value: settings.cart_open_type,
		desktop_overlay_only: modal_with_desktop_only_overlay_val 
	} %}
		{% block modal_head %}
			{% block page_header_text %}{{ "Carrito de Compras" | translate }}{% endblock page_header_text %}
		{% endblock %}
		{% block modal_body %}
			{% snipplet "cart-panel.tpl" %}
		{% endblock %}
	{% endembed %}

	{% if settings.add_to_cart_recommendations %}

		{# Recommended products on add to cart #}

		{% embed "snipplets/modal.tpl" with{modal_id: 'related-products-notification', modal_class: 'bottom modal-overflow-none modal-bottom-sheet h-auto', modal_position: 'bottom', modal_transition: 'slide', modal_footer: false, modal_header_title: true, modal_width: 'centered modal-centered-md-600px', modal_body_class: 'modal-scrollable'} %}
			{% block modal_head %}
				{% block page_header_text %}{{ '¡Agregado al carrito!' | translate }}{% endblock page_header_text %}
			{% endblock %}
			{% block modal_body %}

				{# Product added info #}

				{% include "snipplets/notification-cart.tpl" with {related_products: true} %}
				
				<div class="divider mt-0 mb-3"></div>

				{# Product added recommendations #}

				<div class="js-related-products-notification-container" style="display: none"></div>

			{% endblock %}
		{% endembed %}
	{% endif %}

{% endif %}