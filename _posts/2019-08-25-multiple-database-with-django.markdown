---
author: Levi Leal
layout: post
title:  "Multiple Databases with Django"
subtitle: "Django DB Router"
date:   2019-08-25 00:00:00 +0000
categories: Django, Multi-database
image: /assets/img/code-laptop.jpg
excerpt: brief intro
comments: False
---
<input type="checkbox" id="tldr-toggle">TL;DR

<section class="tldr-content collapse" markdown="1">
In this section we'll create a django app, so if you already have one app, skip this section.

Create folder (workspace)

```bash
mkdir django-multidb
```

Enter the folder
```bash
cd django-multidb
```

### Initialize the environment
```bash
python -m venv .venv
```

### Activate the environment
```bash
. .venv/bin/activate
```

### Install django framework
```bash
pip install django
```

### Start a django project
```bash
django-admin startproject django_multidb .
```

Folders should look like
```bash
.
├── django_multidb
│   ├── __init__.py
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
└── manage.py
```


### Test the project
```bash
python manage.py runserver
```

Enter localhost:8000
Should show the default django start page
```bash
python manage.py migrate
python manage.py createsuperuser

python manage.py runserver
```

Go to localhost:8000/admin and test the login


#### Enter the folder django_multidb
create a app called core
```bash
django-admin startapp core
```


# Create your models here.

```python
#core/models.py
from django.db import models


class Person(models.Model):
    first_name = models.CharField(max_length=30)
    last_name = models.CharField(max_length=50)

    def __str__(self):
        return self.first_name
```

# Register your models here.
```python
#core/admin.py
from django.contrib import admin

from django_multidb.core.models import Person

admin.site.register(Person)
```


#### Register the application core
```python
#settings.py
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'django_multidb.core',
]
```

```bash
python manage.py makemigrations
python manage.py migrate

python manage.py runserver
```


Go to localhost:8000/admin
you should see

AUTHENTICATION AND AUTHORIZATION
Groups	
Users	

CORE
Persons	

Click Persons
Click Add Person

Add as many as you like.

Now you have a basic application working we can start the real thing...
</section>

# Setting up for multidb
We're going to use python-decouple to get env variables

```bash
pip install python-decouple
```

Create a .env file that will contain all environment variables.
```
DEBUG=True
```

```python
#settings.py
import os
from decouple import config
...
DEBUG = config('DEBUG', default=False)
```


We're using dj-database-url to set the database with a url

```bash
pip install pip install dj-database-url
```

```python
#settings.py
import os
from decouple import config
from dj_database_url import parse as dburl
...

DATABASES = {
    'default': dburl(f'sqlite:///{os.path.join(BASE_DIR, "db.sqlite3")}'),
}
```

```bash
python manage.py runserver
```

Go to localhost:8000

All your data should be the same as before


# Create multidb module

```python
#django_multidb/multidb/__init__.py
"""
Select database based on URL variable

Inspired by this Django snipped:

https://djangosnippets.org/snippets/2037/

It's assumed that any view in the system with a cfg keyword argument passed to
it from the urlconf may be routed to a separate database. for example:

  url( r'^(?P<db>\w+)/account/$', 'views.account' )

The middleware and router will select a database whose alias is <db>,
"default" if no db argument is given and raise a 404 exception if not listed in
settings.DATABASES, all completely transparent to the view itself.
"""
import threading
from django.http import Http404
from django.middleware.common import CommonMiddleware

request_cfg = threading.local()


class MultiDbRouterMiddleware(CommonMiddleware):
    """
    The Multidb router middelware.

    he middleware process_view (or process_request) function sets some context
    from the URL into thread local storage, and process_response deletes it. In
    between, any database operation will call the router, which checks for this
    context and returns an appropriate database alias.

    Add this to your middleware, for example:

    MIDDLEWARE += ['django_multidb.multidb.MultiDbRouterMiddleware']
    """
    def process_view(self, request, view_func, args, kwargs):
        from django.conf import settings

        host = request.META.get('HTTP_HOST')
        if host in settings.DB_URL_MAP:
            request_cfg.db = settings.DB_URL_MAP.get(host)
        else:
            request_cfg.db = 'default'

        request.SELECTED_DATABASE = request_cfg.db


class MultiDbRouter(object):
    """
    The multiple database router.

    Add this to your Django database router configuration, for example:

    DATABASE_ROUTERS += ['django_multidb.multidb.MultiDbRouter']
    """
    def _multi_db(self):
        print('_multi_db')
        from django.conf import settings
        if hasattr(request_cfg, 'db'):
            if request_cfg.db in settings.DATABASES:
                return request_cfg.db

    def db_for_read(self, model, **hints):
        result = self._multi_db()
        if result:
            return result

        instance = hints.get('instance')

        if instance is not None and instance._state.db:
            return instance._state.db
        
        return 'default'

    db_for_write = db_for_read


def multidb_context_processor(request):
    """
    This context processor will add a db_name to the request.

    Add this to your Django context processors, for example:

    TEMPLATES['OPTIONS']['context_processors'] +=
        ['django_multidb.multidb.multidb_context_processor']
    """
    print('multidb_context_processor', request.SELECTED_DATABASE)
    if hasattr(request, 'SELECTED_DATABASE'):
        return {'db_name': request.SELECTED_DATABASE}
    else:
        return {}

```

```python
#settings.py
...

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

MIDDLEWARE += ['django_multidb.multidb.MultiDbRouterMiddleware']
...

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

TEMPLATES[0]['OPTIONS']['context_processors'] += ['django_multidb.multidb.multidb_context_processor']
...

DATABASES = {
    'default': dburl(f'sqlite:///{os.path.join(BASE_DIR, "db.sqlite3")}'),
}

DATABASE_ROUTERS = ['django_multidb.multidb.MultiDbRouter']
```


## Add a new database
```python
#settings.py
...
DATABASES = {
    'default': dburl(f'sqlite:///{os.path.join(BASE_DIR, "db.sqlite3")}'),
    'my_ip': dburl(f'sqlite:///{os.path.join(BASE_DIR, "db2.sqlite3")}'),
}
```

## Add url_db mapping

```python
#settings.py
...
DATABASE_ROUTERS = ['django_multidb.multidb.MultiDbRouter']

DB_URL_MAP = {
    'localhost:8000': 'default',
    '127.0.0.1:8000': 'my_ip',
}
```

## Migrate the database and create a user
```bash
python manage.py migrate --database my_ip
python manage.py createsuperuser --database my_ip
```

## Test
```bash
python manage.py runserver
```

Go to localhost:8000 and all your previous data should be there.

Go to 127.0.0.1:8000 and you should get a new empty database.