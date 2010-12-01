function CitedBy(elementIdOrNode, additional) {

    this.iframeSrcFragment = "http://localhost:9393/test/"
    this.queryOffset = 0
    this.queryLimit = 50
    this.abortTimeout = 15 * 1000
    this.parentNode = undefined
    this.doi = undefined

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
	    this.populate()
	} else {
	    this.populateWithError('Couldn\'t find a meta tag for dc.identifier')
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

    CitedBy.prototype.populate = function() {
	var citedByIframe = document.createElement('iframe')
	citedByIframe.setAttribute('src', this.iframeSrcFragment + this.doi)
	this.parentNode.appendChild(citedByIFrame)
    }

    CitedBy.prototype.populateWithError = function(message) {
    	this.parentNode.innerHTML = '<div id="citedby-error">' + message + '</div>'
    }
    
    this.start()
}