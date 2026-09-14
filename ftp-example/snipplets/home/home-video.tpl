{% if settings.video_embed or settings.video_embed_mobile or params.preview %}

	{% set video_has_autoplay = settings.video_type == 'autoplay' %}
	{% set video_has_sound = settings.video_type == 'sound' %}
	{% set custom_video_image = "video_image.jpg" | has_custom_image %}
	{% set has_video_first = settings.home_order_position_1 == 'video' %}
	{% set has_video_text = (settings.video_title or settings.video_subtitle or settings.video_text or (settings.video_button and settings.video_button_url)) or not video_has_autoplay %}
	{% set has_video_button = settings.video_button and settings.video_button_url %}

	{% set video_desktop_url = settings.video_embed %}
	{% set video_mobile_url = settings.video_embed_mobile ? settings.video_embed_mobile : settings.video_embed %}

	<div class="js-section-video home-video-container" data-transition="fade-in-up" {% if settings.head_transparent %}data-header-type="transparent-on-section"{% endif %}>
		<div class="container-fluid">
			<div class="row no-gutters">
				<div class="col-12">
					{% if video_desktop_url %}
						{% include 'snipplets/home/home-video-player.tpl' with {
							video_url: video_desktop_url,
							video_viewport: 'desktop',
							wrapper_class: 'd-none d-md-block',
							player_id: 'home-video-player-desktop',
							video_has_autoplay: video_has_autoplay,
							video_has_sound: video_has_sound,
							custom_video_image: custom_video_image,
							has_video_first: has_video_first,
							has_video_text: has_video_text,
							has_video_button: has_video_button
						} %}
					{% endif %}
					{% if video_mobile_url %}
						{% include 'snipplets/home/home-video-player.tpl' with {
							video_url: video_mobile_url,
							video_viewport: 'mobile',
							wrapper_class: 'd-md-none',
							player_id: 'home-video-player-mobile',
							video_has_autoplay: video_has_autoplay,
							video_has_sound: video_has_sound,
							custom_video_image: custom_video_image,
							has_video_first: has_video_first,
							has_video_text: has_video_text,
							has_video_button: has_video_button
						} %}
					{% endif %}
				</div>
			</div>
		</div>
	</div>
{% endif %}
