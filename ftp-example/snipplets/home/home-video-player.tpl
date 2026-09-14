{% set video_viewport = video_viewport | default('desktop') %}
{% set video_url = video_url | default('') | trim %}
{% set player_id = player_id | default('home-video-player') %}
{% set wrapper_class = wrapper_class | default('') %}

{% if video_url %}
	{% set video_provider = '' %}
	{% set video_id = '' %}

	{% if 'vimeo.com' in video_url %}
		{% set video_provider = 'vimeo' %}
		{% set video_id = video_url | split('?') | first | split('vimeo.com/') | last | split('/') | last %}
	{% elseif '/watch?v=' in video_url %}
		{% set video_provider = 'youtube' %}
		{% set video_id = video_url | split('/watch?v=') | last | split('&') | first %}
	{% elseif 'youtu.be/' in video_url %}
		{% set video_provider = 'youtube' %}
		{% set video_id = video_url | split('youtu.be/') | last | split('?') | first | split('&') | first %}
	{% elseif '/shorts/' in video_url %}
		{% set video_provider = 'youtube' %}
		{% set video_id = video_url | split('/shorts/') | last | split('?') | first %}
	{% elseif 'youtube.com/embed/' in video_url %}
		{% set video_provider = 'youtube' %}
		{% set video_id = video_url | split('/embed/') | last | split('?') | first %}
	{% endif %}

	{% if video_provider and video_id %}
		<div class="{{ wrapper_class }}">
			<div
				class="js-home-video-container lazyload home-video embed-responsive embed-responsive-16by9{% if settings.video_vertical_mobile and video_viewport == 'mobile' %} embed-responsive-1by1{% endif %} position-relative{% if video_has_autoplay and has_video_text %} home-video-overlay{% endif %}"
				data-video="{{ video_id }}"
				data-video-provider="{{ video_provider }}"
				data-video-type="{{ settings.video_type }}"
				data-video-viewport="{{ video_viewport }}"
				data-custom-thumb="{{ custom_video_image ? 'true' : 'false' }}"
				data-allow-custom-thumb="{{ has_video_first or video_has_sound ? 'true' : 'false' }}"
			>
				<a href="#" class="js-play-button video-player"{% if video_has_autoplay %} style="display: none"{% endif %}></a>
				<div class="js-home-video-text-container home-video-text" {% if not has_video_text %}style="display: none;"{% endif %} data-home-video-sound="{{ video_has_sound ? 'true' : 'false' }}">
					<div class="js-play-button video-player-icon mb-4" {% if video_has_autoplay %} style="display: none"{% endif %}>
						<svg class="icon-inline icon-xs svg-icon-text"><use xlink:href="#play"/></svg>
					</div>
					<div class="js-home-video-subtitle subtitle mb-3" {% if not settings.video_subtitle %}style="display: none;"{% endif %}>{{ settings.video_subtitle }}</div>
					<h2 class="js-home-video-title h1 mb-3" {% if not settings.video_title %}style="display: none;"{% endif %}>{{ settings.video_title }}</h2>
					<p class="js-home-video-text mb-3" {% if not settings.video_text %}style="display: none;"{% endif %}>{{ settings.video_text }}</p>
					<a href="{{ settings.video_button_url }}" class="js-home-video-button btn swiper-text-btn" {% if not has_video_button %}style="display: none;"{% endif %}>{{ settings.video_button }}</a>
				</div>
				<div class="js-home-video-image {% if has_video_first and video_has_autoplay and video_viewport == 'mobile' %}d-block{% elseif has_video_first and video_has_autoplay and video_viewport == 'desktop' %}d-none{% endif %}" {% if not (has_video_first or video_has_sound) %} style="display: none"{% endif %}>
					{% if custom_video_image %}
						{% set video_image_static_url = "video_image.jpg" | static_url %}
						{% set video_image_src = video_image_static_url | settings_image_url("large") %}
					{% elseif video_provider == 'youtube' %}
						{% set video_image_src = 'https://img.youtube.com/vi_webp/' ~ video_id ~ '/maxresdefault.webp' %}
					{% else %}
						{% set video_image_src = 'https://vumbnail.com/' ~ video_id ~ '.jpg' %}
					{% endif %}
					<img
						{% if has_video_first %}fetchpriority="high"{% endif %}
						class="home-video-image{% if not has_video_first %} lazyload fade-in{% endif %}"
						{% if not has_video_first %}data-{% endif %}src="{{ video_image_src }}"{% if custom_video_image %}
						{% if not has_video_first %}data-{% endif %}srcset="{{ video_image_static_url | settings_image_url('original') }} 1024w, {{ video_image_static_url | settings_image_url('1080p') }} 1920w"{% endif %}
						alt="{{ 'Video de' | translate }} {{ store.name }}"
					/>
					{% if video_has_autoplay and not theme_editor %}
						<div class="placeholder-shine placeholder-shine-invert"></div>
					{% endif %}
				</div>
				<div class="js-home-video" id="{{ player_id }}"></div>
				{% if video_has_autoplay %}
					<div class="home-video-hide-controls"></div>
				{% endif %}
			</div>
		</div>
	{% endif %}
{% endif %}
