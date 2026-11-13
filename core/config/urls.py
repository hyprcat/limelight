from django.conf import settings
from django.contrib import admin
from django.contrib.staticfiles.urls import staticfiles_urlpatterns
from django.contrib.staticfiles.views import serve as serve_static
from django.urls import include, path, re_path
from django.views import defaults as default_views


def _static_butler(request, path, **kwargs):
    """
    Serve static files using the django static files configuration
    WITHOUT collectstatic. This is slower, but very useful for API
    only servers where the static files are really just for /admin

    Passing insecure=True allows serve_static to process, and ignores
    the DEBUG=False setting
    """
    return serve_static(request, path, insecure=True, **kwargs)


urlpatterns = [
    path(settings.ADMIN_URL, admin.site.urls),
    path("users/", include("limelight_core.users.urls", namespace="users")),
    path("accounts/", include("allauth.urls")),
    # Email and password login, logout and registration come from dj-rest-auth.
    path("user_engine/", include("dj_rest_auth.urls")),
    path("user_engine/register", include("dj_rest_auth.registration.urls")),
    # The app's own API. The user engine is mounted at "user_eng/" because
    # "user_engine/" was already taken by dj-rest-auth above.
    path("user_eng/", include("modules.user_engine.urls")),
    path("video_engine/", include("modules.video_engine.urls")),
    path("lounge_engine/", include("modules.lounge_engine.urls")),
    path("notifier_engine/", include("modules.notifier_engine.urls")),
    re_path(r"^static/(.+)$", _static_butler),
]

if settings.DEBUG:
    # Static file serving when using Gunicorn + Uvicorn for local web socket development
    urlpatterns += staticfiles_urlpatterns()

    # This allows the error pages to be debugged during development, just visit
    # these url in browser to see how these error pages look like.
    urlpatterns += [
        path(
            "400/",
            default_views.bad_request,
            kwargs={"exception": Exception("Bad Request!")},
        ),
        path(
            "403/",
            default_views.permission_denied,
            kwargs={"exception": Exception("Permission Denied")},
        ),
        path(
            "404/",
            default_views.page_not_found,
            kwargs={"exception": Exception("Page not Found")},
        ),
        path("500/", default_views.server_error),
    ]
    if "debug_toolbar" in settings.INSTALLED_APPS:
        import debug_toolbar

        urlpatterns = [path("__debug__/", include(debug_toolbar.urls))] + urlpatterns


admin.site.site_header = "LimeLight Social"
admin.site.index_title = "Master Control."
admin.site.site_title = "LimeLight Social"
