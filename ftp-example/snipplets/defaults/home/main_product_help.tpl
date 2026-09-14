{% set product_view_box = '0 0 1000 1000' %}

<section class="js-product-container section-main-product-home my-5" data-store="home-product-main">
    <div class="container">
        <div class="row justify-content-md-center">
            <div class="col-md-10">
                <div class="row">
                    <div class="col-12 col-md-8 pl-md-0">
                        <div class="row">
                            <div class="col-auto d-none d-md-block">
                                <div class="product-thumbs-container position-relative">
                                    <div class="js-swiper-product-thumbs-demo swiper-product-thumb"> 
                                        <div class="swiper-wrapper">
                                            <div class="swper-slide h-auto w-auto">
                                                <div class="js-product-thumb-demo product-thumb d-block position-relative mb-3 selected">
                                                    {{ component('placeholders/product-placeholder',{
                                                            type: 'dress',
                                                            placeholder_classes: {
                                                                svg_class: 'thumbnail-image',
                                                            }
                                                        })
                                                    }}
                                                </div>
                                            </div>
                                            <div class="swper-slide h-auto w-auto">
                                                <div class="js-product-thumb-demo product-thumb d-block position-relative mb-3">
                                                    {{ component('placeholders/product-placeholder',{
                                                            type: 'dress',
                                                            color: 'red',
                                                            placeholder_classes: {
                                                                svg_class: 'thumbnail-image',
                                                            }
                                                        })
                                                    }}
                                                </div>
                                            </div>
                                            <div class="swper-slide h-auto w-auto">
                                                <div class="js-product-thumb-demo product-thumb d-block position-relative mb-3">
                                                    {{ component('placeholders/product-placeholder',{
                                                            type: 'dress',
                                                            color: 'green',
                                                            placeholder_classes: {
                                                                svg_class: 'thumbnail-image',
                                                            }
                                                        })
                                                    }}
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="product-image-container col-12 col-md p-0">
                                <div class="js-swiper-product-demo swiper-container">
                                    <div class="labels labels-product-slider">
                                        <div class="label label-accent">
                                          -35% OFF
                                        </div>
                                    </div>
                                    <div class="swiper-wrapper">
                                         <div class="js-product-slide-demo w-100 swiper-slide slider-slide" data-image="0" data-image-position="0">
                                            <div class="d-block p-relative">
                                                {{ component('placeholders/product-placeholder',{
                                                        type: 'dress',
                                                        placeholder_classes: {
                                                            svg_class: 'thumbnail-image',
                                                        }
                                                    })
                                                }}
                                            </div>
                                         </div>
                                         <div class="js-product-slide-demo w-100 swiper-slide slider-slide" data-image="1" data-image-position="1">
                                            <div class="d-block p-relative">
                                                {{ component('placeholders/product-placeholder',{
                                                        type: 'dress',
                                                        color: 'red',
                                                        placeholder_classes: {
                                                            svg_class: 'thumbnail-image',
                                                        }
                                                    })
                                                }}
                                            </div>
                                         </div>
                                         <div class="js-product-slide-demo w-100 swiper-slide slider-slide" data-image="2" data-image-position="2">
                                            <div class="d-block p-relative">
                                                {{ component('placeholders/product-placeholder',{
                                                        type: 'dress',
                                                        color: 'green',
                                                        placeholder_classes: {
                                                            svg_class: 'thumbnail-image',
                                                        }
                                                    })
                                                }}
                                            </div>
                                         </div>
                                    </div>
                                    <div class="js-swiper-product-pagination-demo swiper-pagination"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col">
                        <div class="pt-md-3 mt-2 mt-md-0">
                            <h2 class="h4 mb-3 pt-2">{{ "Producto de ejemplo" | translate }}</h2>

                            {# Product price #}

                            {% set price_value = store.country == 'BR' ? '18200' : '182000' %}
                            {% set price_compare_value = store.country == 'BR' ? '28000' : '280000' %}

                            <div class="price-container mb-3 row">
                                <div class="col">
                                    <span class="d-inline-block price-compare">
                                        {{ price_value | money }}
                                    </span>
                                    <span class="d-inline-block">
                                        {{ price_value | money }}
                                    </span>
                                </div>
                            </div>

                            <div class="divider"></div>

                            {# Product form, includes: Variants, CTA and Shipping calculator #}

                            <form id="product_form" class="js-product-form" method="post" action="">
                                <input type="hidden" name="add_to_cart" value="2243561" />

                                <div class="js-product-variants row">
                                    <div class="col col-md-6">
                                        <div class="form-group ">
                                            <label class="form-label " for="variation_1">{{ "Color" | translate }}</label>
                                            <select id="variation_1" class="form-select js-variation-option js-refresh-installment-data  " name="variation[0]">
                                                <option value="{{ "Verde" | translate }}">{{ "Verde" | translate }}</option>
                                                <option value="{{ "Rojo" | translate }}">{{ "Rojo" | translate }}</option>
                                            </select>
                                            <div class="form-select-icon">
                                                <svg class="icon-inline icon-w-14 icon-lg icon-rotate-90"><use xlink:href="#chevron"/></svg>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-row mb-2">
                                    <div class="col-4">
                                        {% embed "snipplets/forms/form-input.tpl" with{
                                        type_number: true, input_value: '1', 
                                        input_name: 'quantity' ~ item.id, 
                                        input_custom_class: 'js-quantity-input', 
                                        input_label: false, 
                                        input_append_content: true, 
                                        input_group_custom_class: 'js-quantity form-quantity', 
                                        form_control_container_custom_class: 'col', 
                                        form_control_quantity: true,
                                        input_min: '1'} %}
                                            {% block input_prepend_content %}
                                            <div class="row m-0 align-items-center">
                                                <span class="js-quantity-down form-quantity-icon btn">
                                                    <svg class="icon-inline icon-w-12 icon-lg"><use xlink:href="#minus"/></svg>
                                                </span>
                                            {% endblock input_prepend_content %}
                                            {% block input_append_content %}
                                                <span class="js-quantity-up form-quantity-icon btn">
                                                    <svg class="icon-inline icon-w-12 icon-lg"><use xlink:href="#plus"/></svg>
                                                </span>
                                            </div>
                                            {% endblock input_append_content %}
                                        {% endembed %}
                                    </div>
                                    <div class="col-8">
                                        <input type="submit" class="js-addtocart js-prod-submit-form btn btn-primary btn-block mb-4 cart" value="{{ 'Agregar al carrito' | translate }}" />
                                    </div>
                                </div>

                             </form>

                            {# Product description #}

                            <div class="home-product-description user-content">
                                <p>{{ "¡Este es un producto de ejemplo! Para poder probar el proceso de compra, debes" | translate }}
                                    <a href="/admin/products" target="_top">{{ "agregar tus propios productos." | translate }}</a>
                                </p>
                            </div>
                        </div>                
                    </div>
                </div>
            </div>
        </div>
    </div>  
</section>