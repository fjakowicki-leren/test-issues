{% set num_messages = 0 %}
{% for adbar in ['ad', 'ad_02', 'ad_03'] %}
    {% set advertising_text = attribute(settings,"#{adbar}_text") %}
    {% if advertising_text %}
        {% set has_advertising_bar = true %}
        {% set num_messages = num_messages + 1 %}
    {% endif %}
{% endfor %}
{% set adbar_animated = settings.ad_bar_animate %}
{% set adbar_section_classes = adbar_animated ? 'section-adbar-animated' %}
{% set adbar_container_classes = adbar_animated ? 'js-adbar-animated adbar-animated' : 'js-swiper-adbar swiper-container' %}
{% set adbar_text_container_classes = adbar_animated ? 'js-adbar-text-container' : 'swiper-wrapper' %}
{% set adbar_text_classes = adbar_animated ? 'mr-4' : 'swiper-slide slide-container' %}

<section class="js-adbar section-adbar {{ adbar_section_classes }}">
    <div class="container-fluid{% if num_messages > 1 and not adbar_animated %} px-1 px-md-3{% endif %}">
        <div class="{{ adbar_container_classes }} font-small text-center">
            <div class="{{ adbar_text_container_classes }}">
                {% if adbar_animated %}
                    {% if num_messages == 1 %}
                        {% set repeat_number = 16 %}
                    {% else %}
                        {% set repeat_number = num_messages == 2 ? '8' : '5' %}
                    {% endif %}
                {% else %}
                    {% set repeat_number = 1 %}
                {% endif %}
                {% for i in 1..repeat_number %}
                    {% for adbar in ['ad', 'ad_02', 'ad_03'] %}
                        {% set advertising_text = attribute(settings,"#{adbar}_text") %}
                        {% set advertising_url = attribute(settings,"#{adbar}_url") %}
                        {% if advertising_text %}
                            <span class="adbar-message {{ adbar_text_classes }} {% if num_messages > 1 and not adbar_animated %}px-4{% endif %}">
                                {% if advertising_url %}
                                    <a href="{{ advertising_url }}" {% if not adbar_animated %}class="d-block w-100"{% endif %}>
                                {% endif %}
                                        {{ advertising_text }}
                                {% if advertising_url %}
                                    </a>
                                {% endif %}
                            </span>
                        {% endif %}
                    {% endfor %}
                {% endfor %}
            </div>
            {% if num_messages > 1 and not adbar_animated %}
                <div class="js-swiper-adbar-prev swiper-button-absolute swiper-button-prev svg-icon-text">
                    <svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#chevron"/></svg>
                </div>
                <div class="js-swiper-adbar-next swiper-button-absolute swiper-button-next svg-icon-text ml-2">
                    <svg class="icon-inline icon-lg"><use xlink:href="#chevron"/></svg>
                </div>
            {% endif %}
        </div>
    </div>
</section>
