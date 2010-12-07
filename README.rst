How?
-------------------------

1. Ensure that there is a dc.identifier meta tag in your page's head element:

::

    <meta name="dc.identifier" content="10.10/this_is_a_doi"/>

2. Include jQuery in your page's head element. It's best to use a content distribution network such as Google's CDN:

::

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js"></script>

3. Include the Cited-by widget Javascript in your page, wherever you want it to appear:

::

    <script src="http://citedby.labs.crossref.org/citedby.min.js"></script>

Below is a complete example.

::

    <html>
      <head>
	<meta name="dc.identifier" content="10.10/this_is_a_doi"/>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js"></script>
      </head>
      <body>
        <div>
          <script src="http://citedby.labs.crossref.org/citedby.min.js"></script>
        </div>
      </body>
    </html>
