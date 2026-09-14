{% set banner = banner | default(false) %}
{% set banner_promotional = banner_promotional | default(false) %}
{% set banner_news = banner_news | default(false) %}
{% set module = module | default(false) %}

{% set theme_editor = params.preview %}

{% if banner %}
    {% set has_banners = settings.banner and settings.banner is not empty %}
    {% set has_mobile_banners = settings.toggle_banner_mobile and settings.banner_mobile and settings.banner_mobile is not empty %}
    {% set section_banner = mobile ? settings.banner_mobile : settings.banner %}
    {% set section_id = mobile ? 'banners-mobile' : 'banners' %}
    {% set section_slider = settings.banner_slider %}
    {% set section_first = settings.home_order_position_1 == 'categories' %}
    {% set section_columns_mobile_2 = settings.banner_columns_mobile == 2 %}
    {% set section_columns_desktop_5 = settings.banner_columns_desktop == 5 %}
    {% set section_columns_desktop_4 = settings.banner_columns_desktop == 4 %}
    {% set section_columns_desktop_3 = settings.banner_columns_desktop == 3 %}
    {% set section_columns_desktop_2 = settings.banner_columns_desktop == 2 %}
    {% set section_columns_desktop_1 = settings.banner_columns_desktop == 1 %}
    {% set section_same_size = settings.banner_same_size %}
    {% set section_text_outside = settings.banner_text_outside %}
{% endif %}
{% if banner_promotional %}
    {% set has_banners = settings.banner_promotional and settings.banner_promotional is not empty %}
    {% set has_mobile_banners = settings.toggle_banner_promotional_mobile and settings.banner_promotional_mobile and settings.banner_promotional_mobile is not empty %}
    {% set section_banner = mobile ? settings.banner_promotional_mobile : settings.banner_promotional %}
    {% set section_id = mobile ? 'banners-promotional-mobile' : 'banners-promotional' %}
    {% set section_slider = settings.banner_promotional_slider %}
    {% set section_first = settings.home_order_position_1 == 'promotional' %}
    {% set section_columns_mobile_2 = settings.banner_promotional_columns_mobile == 2 %}
    {% set section_columns_desktop_4 = settings.banner_promotional_columns_desktop == 4 %}
    {% set section_columns_desktop_3 = settings.banner_promotional_columns_desktop == 3 %}
    {% set section_columns_desktop_2 = settings.banner_promotional_columns_desktop == 2 %}
    {% set section_columns_desktop_1 = settings.banner_promotional_columns_desktop == 1 %}
    {% set section_same_size = settings.banner_promotional_same_size %}
    {% set section_text_outside = settings.banner_promotional_text_outside %}
{% endif %}
{% if banner_news %}
    {% set has_banners = settings.banner_news and settings.banner_news is not empty %}
    {% set has_mobile_banners = settings.toggle_banner_news_mobile and settings.banner_news_mobile and settings.banner_news_mobile is not empty %}
    {% set section_banner = mobile ? settings.banner_news_mobile : settings.banner_news %}
    {% set section_id = mobile ? 'banners-news-mobile' : 'banners-news' %}
    {% set section_slider = settings.banner_news_slider %}
    {% set section_first = settings.home_order_position_1 == 'news_banners' %}
    {% set section_columns_mobile_2 = settings.banner_news_columns_mobile == 2 %}
    {% set section_columns_desktop_4 = settings.banner_news_columns_desktop == 4 %}
    {% set section_columns_desktop_3 = settings.banner_news_columns_desktop == 3 %}
    {% set section_columns_desktop_2 = settings.banner_news_columns_desktop == 2 %}
    {% set section_columns_desktop_1 = settings.banner_news_columns_desktop == 1 %}
    {% set section_same_size = settings.banner_news_same_size %}
    {% set section_text_outside = settings.banner_news_text_outside %}
{% endif %}
{% if module %}
    {% set section_banner = settings.module %}
    {% set section_slider = settings.module_slider %}
    {% set section_id = 'modules' %}
    {% set section_same_size = settings.module_same_size %}
    {% set section_text_outside = true %}
    {% set section_first = settings.home_order_position_1 == 'modules' %}
{% endif %}

{% set banner_classes = module and not section_slider ? 'mb-md-5 pb-md-3' %}
{% set banner_title_classes = module ? 'font-large mb-3' : 'font-large mb-0' %}
{% set banner_description_classes = module ? 'mb-3' : 'textbanner-paragraph' %}
{% set banner_button_prev_classes = module ? 'ml-3' %}
{% set banner_button_next_classes = module ? 'mr-3' %}

<div class="js-{{ section_id }} container{% if not module %}-fluid{% endif %} {% if not module and (has_banners and has_mobile_banners) %}{% if mobile %}d-md-none{% else %}d-none d-md-block{% endif %}{% endif %}">
    <div class="row">
        <div class="js-banner-col col-12 {% if section_slider or module %}p-0{% else %}pl-0{% endif %}">
            {% if section_slider %}
                <div class="js-swiper-{{ section_id }} swiper-container">
                    <div class="js-banner-row banners-slider-wrapper swiper-wrapper">
            {% elseif not module or (module and theme_editor) %}
                <div class="js-banner-row banners-row row">
            {% endif %}
            {% for slide in section_banner %}
                {% if not module or (module and (section_slider or theme_editor)) %}
                    <div class="js-live-preview-banner banner-container {% if section_slider %}swiper-slide slide-container{% else %}grid-item {% if section_columns_mobile_2 %}col-6 banner-2-cols {% endif %}{% if section_columns_desktop_5 %}col-md-5ths{% elseif section_columns_desktop_4 %}col-md-3{% elseif section_columns_desktop_3 %}col-md-4{% elseif section_columns_desktop_2 %}col-md-6{% elseif section_columns_desktop_1 %}col-md-12{% endif %}{% endif %}" data-transition="fade-in-up">
                {% endif %}
                    {% set has_banner_text = slide.title or slide.description or slide.button %}
                    <div class="js-textbanner textbanner {{ banner_classes }}">
                        {% if slide.link %}
                            <a href="{{ slide.link | setting_url }}" class="textbanner-link" aria-label="{{ 'Carrusel' | translate }} {{ loop.index }}">
                        {% endif %}
                        {% if module %}
                            <div class="row no-gutters align-items-center">
                        {% endif %}
                        <div class="textbanner-image{% if not section_same_size %} p-0{% endif %}{% if module %} col-md-6{% if section_same_size %} textbanner-image-md{% endif %}{% else %}{% if has_banner_text and not section_text_outside %} overlay{% endif %}{% endif %}">
                            
                            {% set apply_lazy_load = 
                                not section_first 
                                or not (
                                    loop.first and (
                                        (has_banners and not has_mobile_banners) or 
                                        (has_mobile_banners and mobile) or module
                                    )
                                ) 
                            %}

                            {% if apply_lazy_load %}
                                {% set slide_src = 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==' %}
                            {% else %}
                                {% set slide_src = slide.image | static_url | settings_image_url('large') %}
                            {% endif %}
                            
                            <img 
                                {% if not apply_lazy_load %}fetchpriority="high"{% endif %}
                                {% if slide.width and slide.height %}width="{{ slide.width }}" height="{{ slide.height }}"{% endif %} 
                                {% if apply_lazy_load %}data-{% endif %}src="{{ slide_src }}"
                                {% if apply_lazy_load %}
                                data-sizes="auto" 
                                data-expand="-10"
                                {% endif %}
                                {% if apply_lazy_load %}data-{% endif %}srcset="{{ slide.image | static_url | settings_image_url('large') }} 480w, {{ slide.image | static_url | settings_image_url('huge') }} 640w, {{ slide.image | static_url | settings_image_url('original') }} 1024w, {{ slide.image | static_url | settings_image_url('1080p') }} 1920w" 
                                class="textbanner-image-effect {% if section_same_size %}textbanner-image-background{% else %}img-fluid d-block w-100{% endif %} {% if apply_lazy_load %}lazyautosizes lazyload fade-in{% endif %}" 
                                {% if slide.title %}alt="{{ banner_title }}"{% else %}alt="{{ 'Banner de' | translate }} {{ store.name }}"{% endif %} 
                            />
                            {% if apply_lazy_load %}
                                <div class="placeholder-fade"></div>
                            {% endif %}
                        {% if section_text_outside %}
                            </div>
                        {% endif %}
                        {% if has_banner_text %}
                            {% if banner_promotional and not section_text_outside %}
                                <div class="js-textbanner-text banner-promotional-text swiper-{{ slide.color }}">
                                    <div class="banner-promotional-copy">
                                        {% if slide.title %}
                                            <div class="js-banner-title h1 mb-3">{{ slide.title }}</div>
                                        {% endif %}
                                        {% if slide.description %}
                                            <p class="mb-3 swiper-text-description">{{ slide.description }}</p>
                                        {% endif %}
                                    </div>
                                    {% if slide.button and slide.link %}
                                        <div class="btn swiper-text-btn">{{ slide.button }}</div>
                                    {% endif %}
                                </div>
                            {% else %}
                                <div class="js-textbanner-text textbanner-text{% if module %} textbanner-module col-md-6 px-3 text-center {% if not section_slider and loop.index is even %}order-md-first{% endif %}{% else %}{% if not section_text_outside %} over-image{% endif %}{% if slide.link %} pr-5{% endif %}{% endif %}">
                                    {% if slide.title %}
                                        <div class="js-banner-title {{ banner_title_classes }}">{{ slide.title }}</div>
                                    {% endif %}
                                    {% if slide.description %}
                                        <div class="{{ banner_description_classes }}">{{ slide.description }}</div>
                                    {% endif %}
                                    {% if slide.button and slide.link %}
                                        <div class="btn btn-secondary btn-small mt-2">{{ slide.button }}</div>
                                    {% endif %}
                                    {% if not module and slide.link %}
                                        <div class="textbanner-arrow">
                                            <svg class="icon-inline icon-lg svg-icon-text"><use xlink:href="#arrow-long"/></svg>
                                        </div>
                                    {% endif %}
                                </div>
                            {% endif %}
                        {% endif %}
                        {% if not section_text_outside or module %}
                            </div>
                        {% endif %}
                        {% if slide.link %}
                            </a>
                        {% endif %}
                    </div>
                {% if not module or (module and (section_slider or theme_editor)) %}
                    </div>
                {% endif %}
            {% endfor %}
            {% if section_slider %}
                    </div>
                </div>
            {% else %}
                </div>
            {% endif %}
        </div>
    </div>
    {% if (section_slider and (section_banner and section_banner is not empty)) or theme_editor %}
        <div class="js-swiper-{{ section_id }}-prev swiper-button-prev swiper-nav-circle d-none d-md-flex {{ banner_button_prev_classes }}" aria-label="{{ 'Anterior' | translate }}">
            <svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long-neg"/></svg>
        </div>
        <div class="js-swiper-{{ section_id }}-next swiper-button-next swiper-nav-circle d-none d-md-flex {{ banner_button_next_classes }}" aria-label="{{ 'Siguiente' | translate }}">
            <svg class="icon-inline icon-lg"><use xlink:href="#arrow-long-neg"/></svg>
        </div>
    {% endif %}
</div>