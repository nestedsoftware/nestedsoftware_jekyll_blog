---
title: Flask and SQLAlchemy without the Flask-SQLAlchemy Extension
published: true
description: How to use SQLAlchemy with Flask without the Flask-SQLAlchemy extension
cover_image: /assets/images/2018-06-11-flask-and-sqlalchemy-without-the-flask-sqlalchemy-extension-3cf8.34704/ep5jkljpqv8hjr07rtbo.jpg
canonical_url: https://nestedsoftware.com/2018/06/11/flask-and-sqlalchemy-without-the-flask-sqlalchemy-extension-3cf8.34704.html
tags: python, flask, sqlalchemy
---

When using SQLAlchemy with Flask, the standard approach is to use the Flask-SQLAlchemy extension. 

However, this extension has [some](https://github.com/mitsuhiko/flask-sqlalchemy/pull/250#issuecomment-77504337) [issues](https://stackoverflow.com/questions/28789063/associate-external-class-model-with-flask-sqlalchemy). In particular, we have to use a base class for our SQLAlchemy models that creates a dependency on flask (via `flask_sqlalchemy.SQLAlchemy.db.Model`). Also, an application may not require the additional functionality that the extension provides, such as pagination support.

Let's see if we can find a way to use plain SQLAlchemy in our Flask applications without relying on this extension. 

> This article focuses specifically on connecting a Flask application to SQLAlchemy directly, without using any plugins or extensions. It doesn't address how to get a Flask application working on its own, or how SQLAlchemy works. It may be a good idea to get these parts working separately first.

Below is the code that sets up the SQLAlchemy session (db.py):

```python
import os

from sqlalchemy import create_engine

from sqlalchemy.orm import scoped_session
from sqlalchemy.orm import sessionmaker

engine = create_engine(os.environ['SQLALCHEMY_URL'])

Session = scoped_session(sessionmaker(bind=engine))
```

The key here is `scoped_session`: Now when we use `Session`, SQLAlchemy will check to see if a [thread-local session](http://docs.sqlalchemy.org/en/latest/orm/contextual.html#unitofwork-contextual) exists. If it already exists, then it will use it, otherwise it will create one first. 

The following code bootstraps the Flask application (\_\_init\_\_.py):

```python
from flask import Flask

from .db import Session

from .hello import hello_blueprint

app = Flask(__name__)
app.register_blueprint(hello_blueprint)

@app.teardown_appcontext
def cleanup(resp_or_exc):
    Session.remove()
```
The `@app.teardown_appcontext` decorator will cause the supplied callback, `cleanup`, to be executed when the current application context is torn down. This happens after each request. That way we make sure to release the resources used by a session after each request.

In our Flask application, we can now use `Session` to interact with our database. For example (hello.py):

```python
import json

from flask import Blueprint

from .db import Session

from .models import Message

hello_blueprint = Blueprint('hello', __name__)

@hello_blueprint.route('/messages')
def messages():
    values = Session.query(Message).all()

    results = [{ 'message': value.message } for value in values]

    return (json.dumps(results), 200, { 'content_type': 'application/json' })
```

This should be sufficient for integrating SQLAlchemy into a Flask application. 

>For a more detailed overview of the features Flask-SQLAlchemy provides, see Derrick Gilland's article, [Demystifying Flask-SQLAlchemy](http://derrickgilland.com/posts/demystifying-flask-sqlalchemy/)

We also get the benefit of not having to create a dependency on Flask for our SQLAlchemy models. Below we're just using the standard `sqlalchemy.ext.declarative.declarative_base` (models.py):

```python
from sqlalchemy.ext.declarative import declarative_base

from sqlalchemy import Column, Integer, String

Base = declarative_base()

class Message(Base):
    __tablename__ = 'messages'
    id = Column(Integer, primary_key=True)
    message = Column(String)
    
    def __repr__(self):
        return "<Message(message='%s')>" % (self.message)
```

I could be wrong, but I would prefer to start a project with this approach initially, and only to incorporate the Flask-SQLAlchemy extension later if it turns out to be demonstrably useful. 

>This code is available on github: https://github.com/nestedsoftware/flask_sqlalchemy_starter