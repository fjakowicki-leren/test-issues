{# Promotional banners that work as examples #}

<div class="js-promotional-banner-placeholder">
	<div class="container-fluid pl-0">
		<div class="row">
			<div class="col-md grid-item">
				<div class="textbanner">
					<div class="textbanner-image overlay textbanner-image-empty">
					</div>
					<div class="textbanner-text">
						<div class="h5">{{ "Promoción" | translate }}</div>
						<div class="textbanner-arrow">
							<svg class="icon-inline icon-lg svg-icon-text"><use xlink:href="#arrow-long"/></svg>
						</div>
					</div>
					<div class="placeholder-overlay transition-soft">
						<div class="placeholder-info">
							<svg class="icon-inline icon-3x"><use xlink:href="#edit"/></svg>
							<div class="placeholder-description font-small-xs">
								{{ "Podés mostrar tus promociones desde" | translate }} <strong>"{{ "Banners promocionales" | translate }}"</strong>
							</div>
							{% if not params.preview %}
								<a href="{{ admin_link }}#instatheme=pagina-de-inicio" class="btn-primary btn btn-small placeholder-button">{{ "Editar" | translate }}</a>
							{% endif %}
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

{# Skeleton of "true" section accessed from instatheme.js #}
<div class="js-promotional-banner-top" style="display:none">
	{% include 'snipplets/home/home-banners.tpl' with {'has_banner_promotional': true} %}
</div>