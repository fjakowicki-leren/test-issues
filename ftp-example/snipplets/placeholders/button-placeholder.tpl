<div class="js-addtocart js-addtocart-placeholder btn btn-primary btn-block btn-transition {{ custom_class }} disabled" style="display: none;">
    <div class="d-inline-block">
        <span class="js-addtocart-text">
            {% if icon %}
                <svg class="icon-inline icon-lg item-btn-quickshop-icon svg-icon-text"><use xlink:href="#bag"/></svg>
            {% else %}
                {{ (direct_add ? 'Comprar' : 'Agregar al carrito') | translate }} 
            {% endif %}
        </span>
        <span class="js-addtocart-success transition-container">
            {% if icon %}
                <svg class="icon-inline icon-lg svg-icon-text"><use xlink:href="#check"/></svg>
            {% else %}
                {{ '¡Listo!' | translate }}
            {% endif %}
        </span>
        <div class="js-addtocart-adding {% if not icon %}js-addtocart-adding-text{% endif %} transition-container">
            {% if icon %}
                <svg class="icon-inline icon-spin icon-lg svg-icon-text"><use xlink:href="#spinner-third"/></svg>
            {% else %}
                {{ 'Agregando...' | translate }}
            {% endif %}
        </div>
    </div>
</div>