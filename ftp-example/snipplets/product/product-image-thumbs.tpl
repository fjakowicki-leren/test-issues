<a href="#" {% if media.isVideo %}data-video_id="{{ media.id }}"{% endif %} class="js-product-thumb {% if loop.last and last_open_modal %}js-product-thumb-modal{% endif %} product-thumb d-block position-relative mb-3 {% if loop.first %}selected{% endif %}" style="padding-bottom: {{ media.dimensions['height'] / media.dimensions['width'] * 100}}%;" data-thumb-loop="{{loop.index0}}">
	{% if media.isImage %}
		<img data-sizes="auto" src="{{ 'images/empty-placeholder.png' | static_url }}" data-srcset='{{  media | product_image_url('large') }} 480w, {{  media | product_image_url('huge') }} 640w' class="img-absolute img-absolute-centered lazyautosizes lazyload" {% if media.alt %}alt="{{media.alt}}"{% endif %} />
	{% else %}
		<div class="video-player-icon video-player-icon-small">
			<svg class="icon-inline icon-xs svg-icon-text icon-xs"><use xlink:href="#play"/></svg>
		</div>
		<img alt="{{ 'Video de' | translate }} {% if template != 'product' %}{{ product.name }}{% else %}{{ store.name }}{% endif %}" data-sizes="auto" src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{{ media.thumbnail }}" class="img-absolute img-absolute-centered lazyautosizes lazyload"/>
	{% endif %}
	{% if loop.last and last_open_modal %}
		{% set remaining_media = product.media_count - (loop.index - 1)%}
		<div class="thumb-see-more">
			<span class="label">+{{ remaining_media }}</span>
		</div>
	{% endif %}
</a>
