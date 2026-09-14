{# Product name and breadcrumbs #}

{% if home_main_product %}    
    <h2 class="h4 mb-3 pt-2">{{ product.name }}</h4>
{% else %}
    {% embed "snipplets/page-header.tpl" %}
        {% block page_header_text %}{{ product.name }}{% endblock page_header_text %}
    {% endembed %}
{% endif %}

{# Product price #}

{% set is_subscription_only_product = product.isSubscribable() and product.isSubscriptionOnly() %}

{{ component('nubesdk-slot', { type: "before_product_detail_price" }) }}

{% if not is_subscription_only_product %}
    <div class="js-price-container price-container mb-3 row" data-store="product-price-{{ product.id }}">
        <div class="col">
            {% set price_big_class = settings.payment_discount_price ? 'font-big' %}
            <span class="d-inline-block {{ price_big_class }}">
               <div id="compare_price_display" class="js-compare-price-display price-compare" {% if not product.compare_at_price or not product.display_price %}style="display:none;"{% else %} style="display:block;"{% endif %}>{% if product.compare_at_price and product.display_price %}{{ product.compare_at_price | money }}{% endif %}</div>
            </span>
            <span class="d-inline-flex align-items-center {{ price_big_class }}">
            	<div class="js-price-display" id="price_display" {% if not product.display_price %}style="display:none;"{% endif %} data-product-price="{{ product.price }}">{% if product.display_price %}{{ product.price | money }}{% endif %}</div>
                {{ component('promotional-price-details', {
                    promotional_price_details_classes: {
                        container: 'tooltip-container position-relative ml-1',
                        trigger: 'tooltip-trigger text-accent',
                        icon: 'icon-inline icon-lg icon-w-10',
                        detail_container: 'tooltip-card',
                        detail_row: 'd-flex justify-content-between align-items-center py-1 font-small',
                        detail_divider: 'divider mt-2 mb-2',
                        detail_total: 'font-weight-bold'
                    },
                    promotional_price_details_icon_svg_id: 'tag',
                }) }}
            </span>
        </div>
        {% if settings.product_detail_installments %}
            <div class="col-auto">
                {{ component('installments', {'location' : 'product_detail', container_classes: { installment: "item-installments"}}) }}
            </div>
        {% endif %}
        <div class="col-12">
            {{ component('price-discount-disclaimer', {
                container_classes: 'font-small opacity-60 mt-2',
            }) }}
            {{ component('price-without-taxes', {
                    container_classes: "mt-2 font-small opacity-60",
                })
            }}
            {{ component('payment-discount-price', {
                    visibility_condition: settings.payment_discount_price,
                    location: 'product',
                    container_classes: "mt-2",
                })
            }}
        </div>
    </div>
{% endif %}

{{ component('subscriptions/subscription-price', {
    location: is_subscription_only_product ? 'product_detail',
    subscription_classes: {
        container: 'mb-3',
        prices_container: 'mb-1',
        price_compare: 'price-compare font-big',
        price_with_subscription: 'font-big',
        price_info: 'font-smallest',
        discount_container: 'mt-2',
        price_without_taxes_container: 'mt-2 font-small opacity-60',
    },
}) }}

{{ component('nubesdk-slot', { type: "after_product_detail_price" }) }}

<div class="divider"></div>

{# Product availability #}

{% set product_available = product.available and product.display_price %}

{# Free shipping minimum message #}
{% set has_free_shipping = cart.free_shipping.cart_has_free_shipping or cart.free_shipping.min_price_free_shipping.min_price %}
{% set has_product_free_shipping = product.free_shipping %}
{% set shipping_best_discount = cart.free_shipping.min_price_free_shipping %}
{% set is_full_free_shipping = shipping_best_discount.is_free or not shipping_best_discount.discount_type %}

{% if not product.is_non_shippable and product_available and (has_free_shipping or has_product_free_shipping) %}
    <div class="js-free-shipping-message free-shipping-message mb-4 pb-2">
        <span class="float-left mr-1">
            <svg class="icon-inline icon-w svg-icon-text mr-1"><use xlink:href="#truck"/></svg>
        </span>
        <span class="font-small">
            {% if has_product_free_shipping or is_full_free_shipping %}
                {% set shipping_discount_label = "Envío gratis" | translate %}
            {% else %}
                {% set shipping_discount = shipping_best_discount.discount_type == 'percentage'
                    ? (shipping_best_discount.discount_value | round) ~ '%'
                    : shipping_best_discount.discount_value_money
                %}
                {% set shipping_discount_label = shipping_discount ~ ' ' ~ ('our_components.free_shipping_bar.off_shipping' | tt) %}
            {% endif %}
            <strong class="text-accent">{{ shipping_discount_label }}</strong>
            <span {% if has_product_free_shipping %}style="display: none;"{% else %}class="js-shipping-minimum-label"{% endif %}>
                {{ "superando los" | translate }} <span>{{ cart.free_shipping.min_price_free_shipping.min_price }}</span>
            </span>
        </span>
        {% if not has_product_free_shipping %}
            <div class="js-free-shipping-discount-not-combinable font-small mt-1">
                {{ "No acumulable con otras promociones" | translate }}
            </div>
        {% endif %}
    </div>
{% endif %}

{{ component('promotions-details', {
    promotions_details_classes: {
        container: 'js-product-promo-container mb-3',
        promotion_title: 'mb-2 h6 font-big text-accent',
        valid_scopes: 'font-small mb-0',
        categories_combinable: 'font-small mb-0',
        not_combinable: 'font-small mb-0',
        progressive_discounts_table: 'table mb-2 mt-3',
        progressive_discounts_hidden_table: 'table-body-inverted',
        progressive_discounts_show_more_link: 'btn-link btn-link-primary mb-4',
        progressive_discounts_show_more_icon: 'icon-inline icon-rotate-90',
        progressive_discounts_hide_icon: 'icon-inline icon-rotate-90-neg',
        progressive_discounts_promotion_quantity: 'font-weight-light text-lowercase'
    },
    accordion_show_svg_id: 'chevron',
    accordion_hide_svg_id: 'chevron',
}) }}

{# Gift promotion message #}

{{ component('gift-promotion-message', {
    gift_svg_id: 'gift',
    container_classes: {
        container: 'mb-4 pb-2 font-weight-normal font-small',
        icon: 'icon-inline icon-w svg-icon-text icon-lg mr-1'
    },
}) }}

{# Product form, includes: Variants, CTA and Shipping calculator #}

 <form id="product_form" class="js-product-form" method="post" action="{{ store.cart_url }}" data-store="product-form-{{ product.id }}">
	<input type="hidden" name="add_to_cart" value="{{product.id}}" />
    {% if template == "product" %}
        {% set show_size_guide = true %}
    {% endif %}
 	{% if product.variations %}
        {% include "snipplets/product/product-variants.tpl" with {show_size_guide: show_size_guide} %}
    {% endif %}

    {% set show_product_quantity = product_available and settings.quantity_input %}

    {% if settings.last_product and show_product_quantity %}
        <div class="{% if product.variations %}js-last-product {% endif %}text-accent font-weight-bold mb-4"{% if product.selected_or_first_available_variant.stock != 1 %} style="display: none;"{% endif %}>
            {{ settings.last_product_text }}
        </div>
    {% endif %}

    {{ component('nubesdk-slot', { type: "before_product_detail_add_to_cart" }) }}

    <div class="form-row mb-2">
        {% if show_product_quantity %}
            {% include "snipplets/product/product-quantity.tpl" %}
        {% endif %}

        {{ component('subscriptions/subscription-selector', {
            allow_subscription_only: is_subscription_only_product,
            subscription_only_container: 'p-3',
            subscription_classes: {
                container: 'radio-button-container col-12 mt-2 mb-2',

                radio_button: 'radio-button-item card card-rounded px-3 py-1 mb-2',
                radio_button_label: 'pl-3 mt-1',
                radio_button_text: 'row',
                radio_button_icon: 'radio-button-icons',
                purchase_option_info_container: 'col-auto font-small pr-0',
                purchase_option_price: 'col text-right',
                purchase_option_price_info: 'font-smallest',
                purchase_option_single_frequency: 'mt-2 pt-1 font-small opacity-80',
                purchase_option_discount: 'label label-accent ml-2',

                dropdown_container: 'form-group col-md-9 mt-2 mb-0 px-0 pt-1',
                dropdown_button: 'form-select',
                dropdown_icon: 'form-select-icon icon-inline icon-w-14 icon-lg',
                dropdown_options: 'form-select-options',
                dropdown_option: 'form-select-option row no-gutters',
                dropdown_option_info: 'col pr-4',
                dropdown_option_price: 'col-auto text-right',
                dropdown_option_price_info: 'font-smallest',
                dropdown_option_discount: 'text-accent mt-1',
                dropdown_option_frequency_info: 'font-small mt-1',

                shipping_message: 'accordion mt-2 mb-5',
                shipping_message_icon: 'icon-inline icon-w svg-icon-text mr-1',
                shipping_message_title: 'subtitle',
                shipping_message_text: 'font-small mt-2 ml-4'
            },
            dropdown_icon: true,
            dropdown_icon_svg_id: 'chevron',

            shipping_message_icon: true,
            shipping_message_icon_svg_id: 'truck',
        }) }}
        
        {% set state = store.is_catalog ? 'catalog' : (product.available ? product.display_price ? 'cart' : 'contact' : 'nostock') %}
        {% set texts = {'cart': "Agregar al carrito", 'contact': "Consultar precio", 'nostock': "Sin stock", 'catalog': "Consultar"} %}
        <div class="{% if show_product_quantity and not product.isSubscribable() %}col-8{% else %}col-12{% endif %} {% if product.isSubscribable() %}mt-2{% endif %}">

            {% if settings.product_stock and not settings.quantity_input and product.available and product.display_price %}
                {% include "snipplets/product/product-stock.tpl" with {custom_class: "pb-3"} %}
            {% endif %}

            {# Add to cart CTA #}

            <input type="submit" class="js-addtocart js-prod-submit-form btn btn-primary btn-block mb-4 {{ state }}" value="{{ texts[state] | translate }}" {% if state == 'nostock' %}disabled{% endif %} data-store="product-buy-button" data-component="product.add-to-cart"/>

            {# Fake add to cart CTA visible during add to cart event #}

            {% include 'snipplets/placeholders/button-placeholder.tpl' with {custom_class: "mb-4"} %}

        </div>

        {% if settings.ajax_cart %}
            <div class="col-12">
                <div class="js-added-to-cart-product-message font-small" style="display: none;">
                    <svg class="icon-inline icon-lg svg-icon-text mr-2 d-table float-left"><use xlink:href="#check"/></svg>
                    <span>
                        {{'Ya agregaste este producto.' | translate }}<a href="#" class="js-modal-open js-open-cart js-fullscreen-modal-open btn-link float-right subtitle ml-1" data-toggle="#modal-cart" data-modal-url="modal-fullscreen-cart">{{ 'Ver carrito' | translate }}</a>
                    </span>
                    <div class="divider"></div>
                </div>
            </div>
        {% endif %}

        {# Free shipping visibility message #}

        {% set free_shipping_minimum_label_changes_visibility = has_free_shipping and cart.free_shipping.min_price_free_shipping.min_price_raw > 0 %}

        {% set include_product_free_shipping_min_wording = cart.free_shipping.min_price_free_shipping.min_price_raw > 0 %}

        {% if not product.is_non_shippable and product_available and has_free_shipping and not has_product_free_shipping and is_full_free_shipping %}

            {# Free shipping add to cart message #}

            {% if include_product_free_shipping_min_wording %}

                {% include "snipplets/shipping/shipping-free-rest.tpl" with {'product_detail': true} %}

            {% endif %}

            {# Free shipping achieved message #}

            <div class="js-product-form-free-shipping-message {% if free_shipping_minimum_label_changes_visibility %}js-free-shipping-message{% endif %} text-accent mb-3 w-100" {% if not cart.free_shipping.cart_has_free_shipping %}style="display: none;"{% endif %}>
                {{ "¡Genial! Tenés envío gratis" | translate }}
            </div>

        {% endif %}
    </div>

    {{ component('nubesdk-slot', { type: "after_product_detail_add_to_cart" }) }}

    {# Product installments #}

    {{ component('nubesdk-slot', { type: "before_product_detail_payment_options" }) }}

    {% set installments_info = product.installments_info_from_any_variant %}
    {% set hasDiscount = product.maxPaymentDiscount.value > 0 %}
    {% set show_payments_info = settings.product_detail_installments and product.show_installments and product.display_price and installments_info %}

    {% if not home_main_product and (show_payments_info or hasDiscount) %}

        {# If product detail installments, include container with "see installments" link #}

        <div class="js-accordion-container w-100 mb-3">
            <a href="#" class="js-accordion-toggle py-1 row">
                <div class="col">
                    <svg class="icon-inline icon-w svg-icon-text mr-1"><use xlink:href="#credit-card"/></svg>
                    <span class="subtitle">{{ 'Medios de pago' | translate }}</span>
                </div>
                <div class="col-auto">
                    <span class="js-accordion-toggle-inactive">
                        <svg class="icon-inline svg-icon-text icon-rotate-90"><use xlink:href="#chevron"/></svg>
                    </span>
                    <span class="js-accordion-toggle-active" style="display: none;">
                        <svg class="icon-inline svg-icon-text icon-rotate-90-neg"><use xlink:href="#chevron"/></svg>
                    </span>
                </div>
            </a>
            <div class="js-accordion-content w-100 pt-3" style="display: none;">
                <div {% if installments_info %}data-toggle="#installments-modal" data-modal-url="modal-fullscreen-payments"{% endif %} class="{% if installments_info %}js-modal-open js-fullscreen-modal-open{% endif %} js-product-payments-container row mb-4" {% if not product.display_price or not (product.get_max_installments and product.get_max_installments(false)) %}style="display: none;"{% endif %}>

                    {# Installments #}

                    {% if show_payments_info %}
                        {% set max_installments_without_interests = product.get_max_installments(false) %}
                        {% set installments_without_interests = max_installments_without_interests and max_installments_without_interests.installment > 1 %}
                        {% set installment_text_color = installments_without_interests ? 'text-accent' : '' %}
                        {{ component('installments', {'location' : 'product_detail', container_classes: { installment: "col-12 mb-2 " ~ installment_text_color}}) }}
                    {% endif %}

                    {# Max Payment Discount #}

                    {% set hideDiscountContainer = not (hasDiscount and product.showMaxPaymentDiscount) %}
                    {% set hideDiscountDisclaimer = not product.showMaxPaymentDiscountNotCombinableDisclaimer %}

                    <span class="js-product-discount-container col-12 mb-2" {% if hideDiscountContainer %}style="display: none;"{% endif %}>
                        <span class="text-accent">{{ product.maxPaymentDiscount.value }}% {{'de descuento' | translate }}</span> {{'pagando con' | translate }} {{ product.maxPaymentDiscount.paymentProviderName }}
                        <div class="js-product-discount-disclaimer font-small mt-1" {% if hideDiscountDisclaimer %}style="display: none;"{% endif %}>
                            {{ (product.showMaxPaymentDiscountCombinesWithSomeDiscounts
                                ? "No acumulable con algunas promociones"
                                : "No acumulable con otras promociones")
                            | translate }}
                        </div>
                    </span>

                    <a id="btn-installments" class="btn-link font-small col mt-1" {% if not (product.get_max_installments and product.get_max_installments(false)) %}style="display: none;"{% endif %}>
                        <span class="d-table">
                            {% if not hasDiscount and not settings.product_detail_installments %}
                                <svg class="icon-inline icon-lg svg-icon-primary mr-1"><use xlink:href="#credit-card"/></svg>
                            {{ "Ver medios de pago" | translate }}
                                {% else %}
                                {{ "Ver más detalles" | translate }}
                            {% endif %}
                        </span>
                    </a>
                </div>
            </div>
        </div>
    {% endif %}

    {{ component('nubesdk-slot', { type: "after_product_detail_payment_options" }) }}

    {# Define contitions to show shipping calculator and store branches on product page #}

    {% set show_product_fulfillment = settings.shipping_calculator_product_page and (store.has_shipping or store.branches) and not product.free_shipping and not product.is_non_shippable %}

    {{ component('nubesdk-slot', { type: "before_product_detail_shipping_options" }) }}

    {% if show_product_fulfillment and not home_main_product %}

        {# Shipping calculator and branch link #}

        <div id="product-shipping-container" class="product-shipping-calculator list w-100" {% if not product.display_price or not product.has_stock %}style="display:none;"{% endif %} data-shipping-url="{{ store.shipping_calculator_url }}">
            {% if store.has_shipping %}
                {% include "snipplets/shipping/shipping-calculator.tpl" with {'shipping_calculator_variant' : product.selected_or_first_available_variant, 'product_detail': true} %}
            {% endif %}
        </div>

        {% if store.branches %}
            {# Link for branches #}
            {% include "snipplets/shipping/branches.tpl" with {'product_detail': true} %}
        {% endif %}

    {% endif %}

    {{ component('nubesdk-slot', { type: "after_product_detail_shipping_options" }) }}

 </form>

{% if not home_main_product %}
    {# Product payments details #}

    {% include 'snipplets/product/product-payment-details.tpl' %}
{% endif %}
