{% if (languages | length > 1 and settings.languages_header) and settings.show_tab_nav %}
    <div class="nav-secondary d-flex d-md-none align-items-center mb-3" data-store="account-links">
        <svg class="icon-inline utilities-icon mr-2"><use xlink:href="#globe"/></svg>
        {% if settings.utilities_type_desktop == 'icons_text' %}
            <span class="utilities-text d-none d-md-inline-block">
                {% for language in languages if language.active %}
                    {{ language.country }}
                {% endfor %}
            </span>
        {% endif %}
        <div class="d-inline-block w-auto">
            {% include "snipplets/navigation/navigation-lang.tpl" with { select_custom_class: ' form-select-small' } %}
        </div>
    </div>
{% endif %}
{% if primary_links %}
    <div class="nav-primary">
        <ul class="nav-list" data-store="navigation" data-component="menu">
            {% include 'snipplets/navigation/navigation-nav-list.tpl' with { 'hamburger' : true  } %}
        </ul>
    </div>
{% endif %}