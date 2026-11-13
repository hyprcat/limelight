class CeleryBeatRouter:
    """
    A router to control all database operations on models in the
    django_celery_beat application.
    """
    def db_for_read(self, model, **hints):
        """
        Attempts to read django_celery_beat models go to celery_beat db.
        """
        if model._meta.app_label == 'django_celery_beat':
            return 'celery_beat'
        return None

    def db_for_write(self, model, **hints):
        """
        Attempts to write django_celery_beat models go to celery_beat db.
        """
        if model._meta.app_label == 'django_celery_beat':
            return 'celery_beat'
        return None

    def allow_relation(self, obj1, obj2, **hints):
        """
        Allow relations if a model in the django_celery_beat app is involved.
        """
        if obj1._meta.app_label == 'django_celery_beat' or \
           obj2._meta.app_label == 'django_celery_beat':
            return True
        return None

    def allow_migrate(self, db, app_label, model_name=None, **hints):
        """
        Make sure the django_celery_beat app only appears in the 'celery_beat'
        database.
        """
        if app_label == 'django_celery_beat':
            return db == 'celery_beat'
        return None

