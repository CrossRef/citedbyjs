function CitedBy(elementIdOrNode, additional) {

    this.queryUrlFragment = "http://localhost:9393/test/"
    this.queryOffset = 0
    this.queryLimit = 50
    this.abortTimeout = 15 * 1000
    this.parentNode = undefined
    this.doi = undefined
    this.onSuccess = undefined
    this.onFailure = undefined

    CitedBy.prototype.start = function() {
	if (additional) {
	    this.onSuccess = additional.onSuccess || this.onSuccess
	    this.onFailure = additional.onFailure || this.onFailure
	    this.queryLimit = additional.queryLimit || this.queryLimit
	}
	    
	if (document.getElementById(elementIdOrNode)) {
	    this.parentNode = document.getElementById(elementIdOrNode)
	} else {
	    this.parentNode = elementIdOrNode
	}

	this.doi = this.findDoi()

	if (this.doi) {
	    this.performDoiLookup()
	} else {
	    this.fillWithFailure('Error: Couldn\'t find a meta tag for dc.identifier')
	}
    }

    CitedBy.prototype.findDoi = function() {
	var metaElems = document.getElementsByTagName('meta')
	for (var idx=0; idx<metaElems.length; idx++) {
	    var elem = metaElems[idx]
	    var name = elem.getAttribute('name')
	    if (name.toLowerCase() == 'dc.identifier') {
		var content = elem.getAttribute('content')
		content = content.replace(/^info:doi\//, '')
		content = content.replace(/^doi:/, '')
		return content
	    }
	}
	return undefined
    }

    CitedBy.prototype.performDoiLookup = function() {
	var cb = this

	var req = new XMLHttpRequest
	req.open('GET', this.queryUrlFragment + this.doi, true)
	req.onreadystatechange = function() {
	    if (req.readyState == 4) {
		if (req.responseText) {
		    cb.fillWithResponse(req.responseText)
		} else {
		    cb.fillWithFailure('Error: CrossRef Cited-by query response is empty.')
		}
	    }
	}

	req.send()

	// window.setTimeout(function() {
	//     if (req.readyState != 4) {
	// 	req.abort()
	// 	cb.fillWithFailure('Error: CrossRef Cited-by query is not responding.')
	//     }
	// }, this.abortTimeout)
    }

    CitedBy.prototype.fillWithResponse = function(responseData) {
	var evaledResponse = eval("( " + responseData + " )")

	if (responseData.error) {
	    this.fillWithFailure(evaledResponse)
	} else {
	    var citationsHtml = ''

	    if (evaledResponse.citations.length == 0) {
		citationsHtml = (
		    '<div id="citedby-none">' +
		    'There are no CrossRef Cited-by links for this article.' +
		    '</div>'
		)
	    } else {
	        var citationsHtml = '<div id="citedby-citations">'

		for (var idx in evaledResponse.citations) {
		    var c = evaledResponse.citations[idx]
		    citationsHtml += (
			'<div class="citedby-citation">' +
			'<div class="citedby-title">' + c.title + '</div>' +
			'<div>' +
                        '<span class="citedby-year">' + c.year + ',</span>' +
			'<span class="citedby-journal-title">' + 
                            c.journal_title + 
                        '</span>' +
			'<a class="citedby-doi" href="http://dx.doi.org/' + c.doi + '">' + 
			    c.doi +
			'</a>' +
			'</div>' +
			'<div>' +
                            '<span class="citedby-authors">' + c.authors + '</span>' +
                        '</div>' +
			'</div>'
		    )
		}

		citationsHtml += '</div>'

		this.parentNode.innerHTML = citationsHtml
	    }

	    if (this.onSuccess) {
		this.onSuccess()
	    }
	}
    }

    CitedBy.prototype.fillWithFailure = function(message) {
    	this.parentNode.innerHTML = '<div id="citedby-error">' + message + '</div>'
	
    	if (this.onFailure) {
    	    this.onFailure()
    	}
    }
    
    this.start()
}