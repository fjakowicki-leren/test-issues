{% embed "snipplets/page-header.tpl" %}
	{% block page_header_text %}{{ page.name }}{% endblock page_header_text %}
{% endembed %}

{# Institutional page  #}

{% set centered_page = page.handle == 'quienes-somos' %}

<section class="user-content pb-5">
	<div class="container-fluid">
		<div class="row{% if centered_page %} justify-content-center{% endif %}">
			<div class="col-md-8{% if centered_page %} text-center{% endif %}">
				{{ page.content }}
			</div>
		</div>
	</div>
</section>
