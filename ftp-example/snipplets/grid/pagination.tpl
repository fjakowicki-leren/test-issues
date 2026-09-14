{% if infinite_scroll %}
    {% if pages.current == 1 and not pages.is_last %}
        <div class="text-center mt-5 mb-5">
            <a class="js-load-more btn btn-primary">
                {{ 'Mostrar más productos' | t }}
                <span class="js-load-more-spinner ml-2" style="display:none;">
                    <svg class="icon-inline icon-spin"><use xlink:href="#spinner-third"/></svg>
                </span>
            </a>
        </div>
        <div id="js-infinite-scroll-spinner" class="mt-5 mb-5 text-center w-100" style="display:none">
            <svg class="icon-inline icon-lg svg-icon-text icon-spin"><use xlink:href="#spinner-third"/></svg>
        </div>
    {% endif %}
{% else %}
    {% if pages.numbers %}
        <div class="d-flex justify-content-center align-items-center">
            <a {% if pages.previous %}href="{{ pages.previous }}"{% endif %} class="mr-2 {% if not pages.previous %}opacity-30 disabled{% endif %}">
                <svg class="svg-icon-text icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#chevron"/></svg>
            </a>
            <div class="text-center font-big">
                <span>{{ pages.current }}</span>
                <span>{{'de' | translate }}</span>
                <span>{{ pages.amount }}</span>
            </div>
            <a {% if pages.next %}href="{{ pages.next }}"{% endif %} class="ml-2 {% if not pages.next %}opacity-30 disabled{% endif %}">
                <svg class="svg-icon-text icon-inline icon-lg"><use xlink:href="#chevron"/></svg>
            </a>
        </div>
    {% endif %}
{% endif %}
