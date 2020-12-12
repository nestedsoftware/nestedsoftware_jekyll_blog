---
title: CSRF and Cross-Origin Requests by Example
published: true
description: How does a CSRF token protect us from cross-site request forgery attacks?
tags: security, csrf, html, javascript
cover_image: /assets/images/2020-11-29-csrf-and-cross-origin-requests-by-example-25nb.527705/nvhgtd9luwu92duztyfi.jpg
---

In this article, we will go over how a basic CSRF (cross-site request forgery) attack works and how a [CSRF token](https://owasp.org/www-community/attacks/csrf "csrf") prevents this type of attack. 

We will also show how the browser's [same-origin policy](https://developer.mozilla.org/en-US/docs/Web/Security/Same-origin_policy "same-origin policy") can prevent undesired cross-origin access to resources such as the CSRF token. 

The code for these examples is available on GitHub: 

{% github nestedsoftware/csrf %}

## Set Up

These examples use a simple [Express](https://expressjs.com/) application running in a [docker](https://www.docker.com/) container. To get started, we need to run two web servers. We will consider the "same-origin" server to run on port _3000_. The "cross-origin" server will run on port _8000_. The idea here is that the cross-origin server serves code to the browser and this code then tries to access resources on the same-origin server - thus making a "cross-origin" request.

> A ["scheme/host/port tuple"](https://developer.mozilla.org/en-US/docs/Web/Security/Same-origin_policy) is used to determine whether the destination for a request matches its origin. 

To get started, let's run our two servers:

* Run the same-origin container: `$ ./run.sh`
* View logs for same-origin server: `$ docker logs --follow console-logging-server`
* Run the cross-origin container: `$ ./run.sh console-logging-server-xorigin 8000`
* View logs for cross-origin server: `$ docker logs --follow console-logging-server-xorigin`

## A Basic CSRF Attack

The idea here is that we induce a user to open a malicious web site. This web site will either get the user to submit a form to a site they have already logged in to, or may even trigger the submission automatically. Traditionally, the browser would send along any cookies, including ones used for authentication, as part of that submission. As long as the user was already logged into the site, this would allow the malicious web site to trigger actions on behalf of the user without their awareness. CSRF tokens have been the standard method to prevent so-called CSRF attacks.

As of this writing (November, 2020), a basic CSRF attack, even without CSRF token protection, [will no longer work by default in the Chrome browser](https://blog.chromium.org/2020/02/samesite-cookie-changes-in-february.html "samesite cookie"). The screenshot below shows what happens when we try:

![CSRF Attack Fails in Chrome](/assets/images/2020-11-29-csrf-and-cross-origin-requests-by-example-25nb.527705/aqe30obf1dtxfoccaobd.png "CSRF Attack Fails in Chrome")

For quite some time, the default behaviour has been to submit cookies automatically when a request against a given server is made, even if that request comes from code loaded from a different origin. However, the Chrome browser will no longer submit cookies via a cross-origin request by default. To support cross-origin cookie submission, the cookies must be marked with `SameSite=None` and `Secure` attributes. 

The basic demonstration of a CSRF attack below does currently work in Firefox (version 82.0.3 used for this example), although Firefox is also apparently looking into implementing such a restriction in the future. 

We will load a form from our cross-origin server on port _8000_ and use JavaScript to submit that form to our server on port _3000_:

```html
<!DOCTYPE html>
<html>
  <head>
    <title>Submit form with JS (no csrf protection)</title>
    <script>
      document.addEventListener("DOMContentLoaded", function(event) {
        document.getElementById('hackedForm').submit();
      });
    </script>
  </head>
  <body>
    <form id="hackedForm" action="http://localhost:3000/save_no_csrf_protection" method="post">
    <label for="name">
    <input type="text" id="name" name="name" value="Hacked">
    <input type="submit" value="Save">
  </body>
</html>
```

* To show that a normal form submission works (and to create the session cookie the malicious site will attempt to hijack): submit the form at `http://localhost:3000/form`
* Next, to show that an unprotected cross-origin submission works, go to `http://127.0.0.1:8000/submit_form_xorigin_no_csrf_protection.html` (note: cookies don't distinguish different ports on the same domain, so this trick prevents clobbering the original cookie produced by the legitimate interaction with localhost)
* Now, to show that a CSRF token will prevent the above attack, go to `http://127.0.0.1:8000/submit_form_xorigin_with_csrf_protection.html`

Below is a screenshot showing the results from the 3 scenarios above (note that the 2 cross-origin requests that are forced when the user accesses the malicious web site on port 8000 cause the user's session cookie to be automatically submitted):

![CSRF Attack Scenarios in Firefox](/assets/images/2020-11-29-csrf-and-cross-origin-requests-by-example-25nb.527705/w7fa0skz6a9y8kwlbwko.png "CSRF Attack Scenarios in Firefox")

We can see that in the 3rd case, even though the session cookie gets submitted by the attacker, they don't have access to the CSRF token, so the form submission is rejected.

## Cross-Origin Access Protections

Next, let's take a look at some of the protections in place to prevent cross-origin access. After all, if we are to rely on a CSRF token to prevent CSRF attacks, we need to make sure the attacker can't just get the token and proceed with the attack anyway.

To demonstrate that same-origin access works, enter the following into the browser's address field (check the browser console to make sure there are no errors):
  * `http://localhost:3000/load_and_submit_form_with_fetch.html`
  * `http://localhost:3000/load_form_into_iframe.html`
  * `http://localhost:3000/load_form_into_iframe_no_embedding.html`
  * `http://localhost:3000/jquery_run_and_try_to_load_source.html`  
 
### Cross-Origin Form Load/Submission

The following URL shows that loading and automatically submitting a form cross-origin doesn't work: `http://localhost:8000/load_and_submit_form_with_fetch.html`

The code uses javascript to load the form from port _3000_ into the dom, then updates a form field and submits the form:

```html
<!DOCTYPE html>
<html>
  <head>
    <title>Fetch and submit form with JS (try to get csrf token)</title>
    <script>
      fetch("http://localhost:3000/form")
      .then(r => r.text())
      .then(d => {
        const action = new DOMParser()
          .parseFromString(d, 'text/html')
          .forms[0]
          .getAttribute('action');
        const csrfToken = new DOMParser()
          .parseFromString(d, 'text/html')
          .forms[0]
          .elements['csrfToken']
          .value;

        const data = new URLSearchParams();
        data.append("name", "injected name");
        data.append("csrfToken", csrfToken);

        fetch('http://localhost:3000' + action, {
          method: 'POST',
          body: data
        })
        .then(r => console.log("status: ", r.status));
      })
      .catch(e => console.log(e));
    </script>
  </head>
  <body>
  </body>
</html>
```
Here is what happens:

![Browser blocks cross-origin request](/assets/images/2020-11-29-csrf-and-cross-origin-requests-by-example-25nb.527705/e79rf0grr4d1dk3yzgk9.png)

As we can see, the browser prevents the javascript from loading the form because it is a cross-origin request (we log an exception in the `fetch` call to the browser's console: `load_and_submit_form_with_fetch.html:30 TypeError: Failed to fetch`).

It's important to understand that the browser does issue the `fetch` request to load the form and the server does send the form back to the browser, including any CSRF token (note: the `404` response is just because the "favicon.ico" file is missing).

The wireshark trace for the `fetch` request is shown below:

![wireshark trace of fetch request being sent](/assets/images/2020-11-29-csrf-and-cross-origin-requests-by-example-25nb.527705/ixq0e6efiz0mzx6jnepn.png)

The wireshark trace for the response from the server is shown below:

![wireshark trace of response to fetch request](/assets/images/2020-11-29-csrf-and-cross-origin-requests-by-example-25nb.527705/gdcp6uv3hpxgr3o83rtf.png)

However, the same-origin policy prevents this information from reaching the code that tries to access it.

### Cross-Origin IFrame

Let's see if cross-origin loading of a form into an iframe works: `http://localhost:8000/load_form_into_iframe.html`.

The HTML file loaded from the cross-origin server (_port 8000_) attempts to load the contents of the form at port _3000_ into an iframe and to populate the contents of the form:

```html
<!DOCTYPE html>
<html>
  <head>
    <title>IFrame Form Loader</title>
    <script>
      document.addEventListener("DOMContentLoaded", function(event) { 
        const iframe = document.getElementById("iframe");
        iframe.addEventListener("load", function() {
          try {
            const formField = iframe.contentWindow.document.getElementById("name");  
            if (formField) {
              formField.value = "filled by JS code";
            }
          } catch (e) {
            console.error(e);
          }
          try {
            const csrfToken = iframe.contentWindow.document.getElementById("csrfToken");
            if (csrfToken) {
              console.log("csrfToken", csrfToken.value);
            }
          } catch (e) {
            console.error(e)
          }
        });
      });
    </script>
  </head>
  <body>
    <iframe id="iframe" src="http://localhost:3000/form" title="iframe tries to load form - hardcoded to port 3000">
  </body>
</html>
```
The following wireshark trace shows that the request for the form is sent successfully:

![load form into iframe cross-origin request is sent](/assets/images/2020-11-29-csrf-and-cross-origin-requests-by-example-25nb.527705/vtdo05yggaqzos42lins.png)

The browser also receives the form successfully from the server:

![Load form into iframe cross-origin browser received response](/assets/images/2020-11-29-csrf-and-cross-origin-requests-by-example-25nb.527705/jq50pdz316pspo37p807.png)

It's interesting to note that the cross-origin script is able to successfully load the form into an iframe. However, the same-origin policy prevents the script from reading the CSRF token or populating the form with data:

![Load form into iframe reading/writing not allowed](/assets/images/2020-11-29-csrf-and-cross-origin-requests-by-example-25nb.527705/d9lm72oqdbepgdveb7md.png)

If the user fills out this form and submits it manually, it will work though, even when loaded cross-origin. 

This feels dangerous to me. We can add some headers to prevent the browser from allowing the form to be embedded by a cross-origin request in the first place:

```javascript
app.get('/form_no_embedding', (req, res) => {
  console.log({ url: req.url, method: req.method, headers: req.headers });
  res.header('X-Frame-Options', 'SAMEORIGIN');
  res.header('Content-Security-Policy', "frame-ancestors 'self'");
  res.render('simple_form', {csrfToken: req.session.csrfToken});
});
```
If we try the same technique on a form that has been protected by such headers, we see that the browser will not load the form into the iframe anymore. `http://localhost:8000/load_form_into_iframe_no_embedding.html`: 

![headers prevent cross-origin loading into iframe](/assets/images/2020-11-29-csrf-and-cross-origin-requests-by-example-25nb.527705/axxey86kr3ei7cwv92rr.png)

### Script Tags

Script tags are interesting, in that the browser won't place restrictions on script execution. A script can include JavaScript code from another site, and that code will successfully execute. However, the page won't be able to access the source code of that script. The following code successfully executes a bit of [jQuery](https://jquery.com/) code loaded from the same-origin site:

```html
<!DOCTYPE html>
<html>
  <head>
    <title>jQuery: running always works x-origin, but not accessing source</title>
    <script id="jq" type="text/javascript" src="http://localhost:3000/js/jquery-3.5.1.js"></script>
  </head>
  <body>
    <div id="execute_jquery"></div>
    <div id="jquery_source_code"></div>
    <script>
      $("#execute_jquery").html("<b>I work with same origin and cross origin!</b>");
    </script>
    <script>
      const script = document.getElementById("jq");
      const url = script.src;
      fetch(url)
      .then(r => r.text())
      .then(d => document.getElementById("jquery_source_code").innerHTML = d)
      .catch(error => console.log(error));
    </script>

  </body>
</html>
```
However, the cross-origin request, `http://localhost:8000/jquery_run_and_try_to_load_source.html`, cannot access the jQuery source code:

![source code of script tag cannot be accessed cross-origin](/assets/images/2020-11-29-csrf-and-cross-origin-requests-by-example-25nb.527705/fabqhzot3csm6h501r9n.png)

When this same page is loaded from the same-origin server on port _3000_, the entire source code of jQuery is displayed on the page:

![source code of script tag cann be accessed same-origin](/assets/images/2020-11-29-csrf-and-cross-origin-requests-by-example-25nb.527705/fpb9ac2yomrzl65rua5m.png)

When it is a cross-origin request though, the browser does not allow it.

## Conclusion

Hopefully this article has been helpful in clarifying how the browser's same-origin policy works together with CSRF tokens to prevent CSRF attacks. It's important to understand that the browser enforces this policy on browser "reads", that is, on the responses sent back from the server to the browser.

Frankly, this approach of leaving it until the last moment to prevent malicious code from working strikes me as rather brittle. I welcome Chrome's new [samesite cookie](https://blog.chromium.org/2020/02/samesite-cookie-changes-in-february.html "samesite cookie") behaviour mentioned earlier in the article. It seems much more secure. If all browsers implement this, perhaps in the future we can start getting away from needing such elaborate and error-prone protection measures. 

As an example of the kind of complexity we have to deal with when working with CSRF tokens, should we [refresh our CSRF tokens for each request](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html#synchronizer-token-pattern), as recommended by OWASP, despite various problems this creates with the browser's "back" button or with using multiple tabs? Or is it sufficient to set up the CSRF token at the session level? For the latter, be sure to refresh the csrf token [at login](https://security.stackexchange.com/a/22936 "issue new csrf token on principal-change inside a session"). 

Separately from the discussion of CSRF in this article, when possible, it is a good idea to make cookies [secure and httponly](https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#Creating_cookies "secure and httponly cookies") as well as [SameSite=strict](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie/SameSite). While it is unrelated to this article, also please always remember to [sanitize web inputs](https://kevinsmith.io/sanitize-your-inputs "sanitize your inputs") to ward off [XSS attacks](https://owasp.org/www-community/attacks/xss/).

> The examples in this article are meant to illustrate the basic concept of how CSRF tokens working . Please don't use the code in production. Instead, leverage a well-established library appropriate to the particular Web technology you are using.
