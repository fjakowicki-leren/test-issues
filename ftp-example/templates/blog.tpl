<div class="container mb-5">
    {% embed "snipplets/page-header.tpl" with { breadcrumbs: true, page_header_custom_classes: 'px-0' } %}
        {% block page_header_text %}{{ "Blog" | translate }}{% endblock page_header_text %}
    {% endembed %}
    <section class="blog-page">
        <div class="row">
            {% for post in blog.posts %}
                <div class="col-md-4">
                    {{ component(
                        'blog/blog-post-item', {
                            image_lazy: true,
                            image_lazy_js: true,
                            post_item_classes: {
                                item: 'item',
                                image_container: '',
                                image: 'img-absolute img-absolute-centered fade-in',
                                information: 'item-description px-0',
                                title: 'item-name mb-2',
                                summary: 'mb-3 font-big',
                                read_more: 'btn-link btn-link-primary',
                            },
                        })
                    }}
                </div>
            {% endfor %}
        </div>
        {% include 'snipplets/grid/pagination.tpl' with {'pages': blog.pages} %}
    </section>
</div>
