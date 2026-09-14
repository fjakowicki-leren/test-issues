{% set message_name = institutional ? 'institutional' : 'welcome' %}
{% set message_title = institutional ? settings.institutional_message : settings.welcome_message %}
{% set message_description = institutional ? settings.institutional_text : settings.welcome_text %}

{% if message_title or message_description %}
	<section class="section-{{ message_name }}-home py-5" data-store="home-{{ message_name }}-message">
		<div class="container py-3">
			<div class="row justify-content-md-center">
				<div class="col-md-6 text-center">
					<h2 class="js-{{ message_name }}-message-title h1{% if not message_title %} mb-0{% endif %}" {% if not message_title %}style="display: none"{% endif %}>{{ message_title }}</h2>
					<p class="js-{{ message_name }}-message-text" {% if not message_description %}style="display: none"{% endif %}>{{ message_description }}</p>
				</div>
			</div>
		</div>
	</section>
{% endif %}
