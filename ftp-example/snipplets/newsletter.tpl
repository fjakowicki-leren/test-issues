{% set newsletter_contact_error = contact.type == 'newsletter' and not contact.success %}

{% set newsletter_title = home_newsletter ? settings.home_news_title : settings.news_title %}
{% set newsletter_text = settings.home_news_text %}

{% set newsletter_classes = home_newsletter ? 'px-3 px-md-5' : 'pb-2 mb-3' %}
{% set newsletter_title_classes = home_newsletter ? 'h4 mb-2' : 'font-big text-uppercase font-weight-bold mb-2' %}
{% set newsletter_form_group_class = home_newsletter ? 'mb-0' %}
{% set newsletter_alert_classes = home_newsletter ? 'mt-3 mb-0' %}

{% if (settings.news_show and not home_newsletter) or home_newsletter %}
    <div class="js-newsletter newsletter {{ newsletter_classes }}">
        {% if (settings.news_title and not home_newsletter) or home_newsletter %}
            <div class="js-home-newsletter-title {{ newsletter_title_classes }}" {% if (home_newsletter and not newsletter_title) %} style="display: none"{% endif %}>{{ newsletter_title }}</div>
        {% endif %}
        {% if home_newsletter %}
            <p class="js-home-newsletter-text mb-2" {% if not newsletter_text %} style="display: none"{% endif %}>{{ newsletter_text }}</p>
        {% endif %}
        
        <form method="post" action="/winnie-pooh" onsubmit="this.setAttribute('action', '');" data-store="{{ form_data_store }}">
            <div class="newsletter-form input-append">
              
                {% embed "snipplets/forms/form-input.tpl" with{
                    input_for: 'email', type_email: true, 
                    input_name: 'email', 
                    input_id: 'email', 
                    input_placeholder: 'Email' | translate, 
                    input_aria_label: 'Email' | translate,
                    input_group_custom_class: newsletter_form_group_class } %}
                {% endembed %}

            <div class="winnie-pooh" style="display: none;">
                <label for="winnie-pooh-newsletter">{{ "No completar este campo" | translate }}</label>
                <input id="winnie-pooh-newsletter" type="text" name="winnie-pooh"/>
            </div>
            <input type="hidden" name="name" value="{{ "Sin nombre" | translate }}" />
            <input type="hidden" name="message" value="{{ "Pedido de inscripción a newsletter" | translate }}" />
            <input type="hidden" name="type" value="newsletter" />
            <input type="submit" name="contact" class="btn newsletter-btn" value="{{ "Enviar" | translate }}" />
            <svg class="icon-inline newsletter-btn"><use xlink:href="#arrow-long"/></svg>
            </div>
        </form>

        {% if contact and contact.type == 'newsletter' %}
            {% if contact.success %}
                <div class="alert alert-success {{ newsletter_alert_classes }}">{{ "¡Gracias por suscribirte! A partir de ahora vas a recibir nuestras novedades en tu email" | translate }}</div>
            {% else %}
                <div class="alert alert-danger {{ newsletter_alert_classes }}">{{ "Necesitamos tu email para enviarte nuestras novedades." | translate }}</div>
            {% endif %}
        {% endif %}
    </div>
{% endif %}