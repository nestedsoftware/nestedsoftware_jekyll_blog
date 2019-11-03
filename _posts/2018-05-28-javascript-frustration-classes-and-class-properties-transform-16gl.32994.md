---
title: JavaScript Frustration&#58; Classes and Class Properties Transform
published: true
description: JavaScript class properties transform
cover_image: /assets/images/2018-05-28-javascript-frustration-classes-and-class-properties-transform-16gl.32994/ec864y2swcurr7aj4apd.jpg
canonical_url: https://nestedsoftware.com/2018/05/28/javascript-frustration-classes-and-class-properties-transform-16gl.32994.html
tags: javascript, react, propertiestransform
---

Recently I have been learning React and I ran into something in JavaScript that I hadn't expected. 

Here is an example of some code I was playing with. This code is a modified version of the code at https://reacttraining.com/react-router/web/example/auth-workflow. 

```jsx
class Login extends React.Component {
  constructor() {
    this.state = {
      redirectToReferrer: false
    }
  }

  login() {
    fakeAuth.authenticate(() => {
      //the problem is here
      this.setState(() => ({ 
        redirectToReferrer: true
      }))
    })
  }

  render() {
    //...some additional logic here
    return (
      <div>
        <p>You must log in to view the page</p>
        <button onClick={this.login}>Log in</button>
      </div>
    )
  }
}
```
I was rather shocked to find that when I clicked on the button, the browser complained that the `setState` method did not exist! 

It turns out that even with the [`class` syntax](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Classes) that debuted in ES2015, the methods of the class are not bound to a given instance. Somehow I had not realized that this was the case. It's the same old problem of `this` depending on the [calling context](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/this#Function_context). If we want the code to work, we have to bind the method ourselves, e.g. like so:

```javascript
class Login extends React.Component {
  constructor() {
    super()
    this.login = this.login.bind(this);
    //etc...
  }
}
```
Now, the actual example that I was looking at online uses a syntax I was not familiar with, presumably to get around this very problem. It turns out that it's called [Class properties transform](https://babeljs.io/docs/plugins/transform-class-properties). It's currently available with [Babel](https://babeljs.io/) using the [stage-2](https://babeljs.io/docs/plugins/preset-stage-2/) preset. Here's what the new syntax looks like:

```jsx
class Login extends React.Component {
  //class properties transform
  state = {
    redirectToReferrer: false
  }
  
  //class properties transform
  login = () => {
    fakeAuth.authenticate(() => {
      this.setState(() => ({
        redirectToReferrer: true
      }))
    })
  }

  render() {
    //...some additional logic here
    return (
      <div>
        <p>You must log in to view the page</p>
        <button onClick={this.login}>Log in</button>
      </div>
    )
  }
}
```

I don't know quite what to make of this syntax. I'm not a language or JavaScript expert, but it just doesn't look right to me. 

If we replace `class` with `function`, it reminds me of something like this:

```javascript
function Login() {
  this.state = {
    redirectToReferrer: false
  }

  this.login = () => {
    fakeAuth.authenticate(() => {
      this.setState(() => ({
        redirectToReferrer: true
      }))
    })
  } 
}
```

If we create an instance using `new Login()`, `this.setState` will now work regardless of the calling context. 

However, is using classes and adding this new transform syntax really worthwhile in that case? It's as though this new syntax is trying to bridge the gap between what can be done with the `function` and `class` syntax: We can't just write `this.state = value` in a `class` outside of the constructor, but now we can kind of do it after all with transform class properties. In that case, maybe it should just have been allowed in `class` in the first place.

I also played around a bit to see how this new syntax deals with inheritance. If we have a normal method in a superclass and an arrow function with the same name in a subclass, a call to `super` in the subclass' method actually works. 

However, `super` doesn't currently work if both the superclass and the subclass use the arrow syntax:

```javascript
class BaseClass {
	arrowFunction = () => {
	  console.log('BaseClass arrowFunction called')
	}
}

class SubClass extends BaseClass {
	arrowFunction = () => {
		super.arrowFunction()
		console.log('SubClass arrowFunction called')
	}
}

const t = new SubClass()
t.arrowFunction()
```

When we transpile this code using Babel with 'env' and 'stage-2' presets, and try to run the resulting code in node, we get:

```
C:\dev\test.js:34
_get(SubClass.prototype.__proto__ 
  || Object.getPrototypeOf(SubClass.prototype), 'arrowFunction', _this).call(_this);
                                                                                                                    
                                                                    ^
TypeError: Cannot read property 'call' of undefined
    at SubClass._this.arrowFunction (C:\dev\test.js:34:96)
```

It appears that `arrowFunction` is not getting resolved in the prototype chain. I don't know if this is the intended behaviour or a bug.

Stuff like this gets me frustrated with JavaScript. It kind of feels as though JavaScript is chasing its own tail, adding syntactic sugar on top of more syntactic sugar, and the end result is still confusing. I don't know what the internal considerations may be here, but it just seems that if JavaScript is to have a `class` syntax, doing so in a way that's more orthogonal, that doesn't require adding new syntax all the time, would be nice.

Am I wrong to be frustrated with this syntax? I'm always open to different perspectives. 
