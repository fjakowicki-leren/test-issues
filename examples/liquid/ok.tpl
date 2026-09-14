{% set title = product.name %}
{% if title %}
  {% for image in product.images %}
    {{ image | settings_image_url("large") }}
  {% endfor %}
{% elseif product.handle %}
  ok
{% else %}
  vacio
{% endif %}
{% block card_body %}{% endblock %}
