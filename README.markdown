# Cited-by JS

## How?

1. Ensure there is a dc.identifier meta tag in your DOI landing page:

    <meta name="dc.identifier" content="10.10/this_is_a_doi"/>

2. Include jQuery in your page's <head> element. It's best to use a content distribution network such
   Google's CDN:

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js"></script>

3. Include the Cited-by widget Javascript in your page, wherever you want it to appear:

    <html>
      <head>
	<meta name="dc.identifier" content="10.10/this_is_a_doi"/>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js"></script>
      </head>
      <body>
        <div id="citedby">
          <script src="citedby.labs.crossref.org/citedby.min.js"></script>
        </div>
      </body>
    </html>
