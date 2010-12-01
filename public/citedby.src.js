function CitedBy(scriptIdOrNode, additional) {

    this.iframeSrcFragment = "http://localhost:9393/test/"
    this.queryOffset = 0
    this.queryLimit = 50
    this.abortTimeout = 15 * 1000
    this.scriptNode = undefined
    this.doi = undefined

    CitedBy.prototype.start = function() {
	if (additional) {
	    this.onSuccess = additional.onSuccess || this.onSuccess
	    this.onFailure = additional.onFailure || this.onFailure
	    this.queryLimit = additional.queryLimit || this.queryLimit
	}
	    
	if (document.getElementById(scriptIdOrNode)) {
	    this.scriptNode = document.getElementById(scriptIdOrNode)
	} else {
	    this.scriptNode = scriptIdOrNode
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
	var parentWidth = this.scriptNode.parentNode.clientWidth
	var parentHeight = this.scriptNode.parentNode.clientHeight
	
	var citedByIframe = document.createElement('iframe')
	citedByIframe.setAttribute('src', this.iframeSrcFragment + this.doi)
	citedByIframe.setAttribute('frameborder', '0')
	citedByIframe.setAttribute('hspace', '0')
	citedByIframe.setAttribute('vspace', '0')
	citedByIframe.setAttribute('style', 'overflow: auto;')
	citedByIframe.setAttribute('width', parentWidth)
	citedByIframe.setAttribute('height', parentHeight)
	this.scriptNode.parentNode.replaceChild(citedByIframe, this.scriptNode)
    }

    CitedBy.prototype.populateWithError = function(message) {
    	this.parentNode.innerHTML = '<div id="citedby-error">' + message + '</div>'
    }
    
    this.start()
}

var scriptTags = document.getElementsByTagName('script')
for (var idx=0; idx<scriptTags.length; idx++) {
    var script = scriptTags[idx]
    if (script.getAttribute('src') == 'citedby.src.js') {
	new CitedBy(script)
	break
    }
}
  
