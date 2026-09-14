{% set notification_without_recommendations_classes = 'js-alert-added-to-cart notification-floating notification-cart-container notification-hidden' %}
{% set notification_wrapper_classes = 
    related_products ? 'row align-items-center' 
    : not related_products and not add_to_cart_fixed ? notification_without_recommendations_classes ~ ' notification-fixed' 
    : notification_without_recommendations_classes 
%}

<div class="{{ notification_wrapper_classes }} {% if not related_products %}{% if settings.show_tab_nav %}notification-with-tabnav position-fixed{% endif %} {% if settings.search_big_mobile %}notification-with-big-search{% endif %}{% endif %}" {% if not related_products %}style="display: none;"{% endif %}>
    <div class="{% if related_products %}col-md-6 mb-3 mb-md-0{% else %}notification notification-primary notification-cart position-relative{% endif %}">
        {% if not related_products %}
            <div class="js-cart-notification-close notification-close mr-2 mt-2">
                <svg class="icon-inline icon-lg notification-icon"><use xlink:href="#times"/></svg>
            </div>
        {% endif %}
        <div class="js-cart-notification-item row{% if related_products %} align-items-center{% endif %}" data-store="cart-notification-item">
            <div class="{% if related_products %}col-md-3 {% endif %}col-2 pr-0 notification-img">
                <img src="" class="js-cart-notification-item-img img-fluid" />
            </div>
            <div class="{% if related_products %}col-md-9 {% endif %}col-10 text-left">
                <div class="mb-1 mr-4">
                    <span class="js-cart-notification-item-name"></span>
                    <span class="js-cart-notification-item-variant-container" style="display: none;">
                        (<span class="js-cart-notification-item-variant"></span>)
                    </span>
                </div>
                <div class="d-flex align-items-center mt-2 mb-2">
                    <span class="js-cart-notification-item-quantity"></span>
                    <span> x </span>
                    <span class="js-cart-notification-item-price"></span>
                    <span class="js-cart-notification-discount-label ml-2" style="display: none;">
                        <span class="label label-accent label-small font-smallest px-2 py-1"><strong class="js-cart-notification-discount-percentage"></strong></span>
                    </span>
                </div>
                {% if not related_products %}
                    <strong>{{ '¡Agregado al carrito!' | translate }}</strong>
                {% endif %}
            </div>
        </div>
        {% if related_products %}
            </div>
            <div class="col-md-6">
        {% else %}
            <div class="divider my-2"></div>
        {% endif %}
        <div class="row{% if not related_products %} h6{% endif %} mb-3">
            <span class="col-auto text-left{% if not related_products %} ml-2{% endif %}">
                <span>{{ "Total" | translate }}</span> 
                (<span class="js-cart-widget-amount">
                    {{ "{1}" | translate(cart.items_count ) }} 
                </span>
                <span class="js-cart-counts-plural" style="display: none;">
                    {{ 'productos' | translate }}):
                </span>
                <span class="js-cart-counts-singular" style="display: none;">
                    {{ 'producto' | translate }}):
                </span>

            </span>
            <strong class="js-cart-total col text-right">{{ cart.total | money }}</strong>
        </div>
        <a href="#" class="{% if related_products %}js-modal-close{% else %}js-cart-notification-close{% endif %} js-modal-open js-open-cart js-fullscreen-modal-open btn btn-primary btn-medium w-100 d-inline-block" data-toggle="#modal-cart" data-modal-url="modal-fullscreen-cart">
            {{'Ver carrito' | translate }}
        </a>
        {% if related_products %}
            </div>
        {% endif %}
    </div>
</div>