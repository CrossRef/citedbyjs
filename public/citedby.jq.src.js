function CitedBy(scriptObj) {

    this.iframeSrcFragment = "http://localhost:9393/"
    this.scriptObj = undefined
    this.doi = undefined
    this.containerObj = undefined

    CitedBy.prototype.start = function() {
	this.scriptObj = scriptObj
	this.doi = this.findDoi()

	if (this.doi) {
	    this.populate()
	} else {
	    this.populateWithError('Couldn\'t find a meta tag for dc.identifier')
	}

	$(window).resize(this.makeResizer())
    }

    CitedBy.prototype.findDoi = function() {
        var dcId = undefined
        $('meta[name="dc.identifier"]').each(function() {
            dcId = ($(this).attr('content')
                    .replace(/^info:doi\//, '')
                    .replace(/^doi:/, ''))
        })
        return dcId
    }

    CitedBy.prototype.populate = function() {
        this.containerObj = $('<iframe/>', {
            src: this.iframeSrcFragment + this.doi,
            frameborder: 0,
            hspace: 0,
            vspace: 0,
            style: 'overflow: auto',
            width: this.scriptObj.parent().width(),
            height: this.scriptObj.parent().height()
        })
        this.scriptObj.replaceWith(this.containerObj)
    }

    CitedBy.prototype.populateWithError = function(message) {
        this.scriptObj.replaceWith($('<div/>', {
            id: 'citedby-error'
        }))
        $('#citedby-error').text(message)
    }

    CitedBy.prototype.makeResizer = function() {
	var cb = this
	return function() {
	    cb.containerObj.width(cb.containerObj.parent().width())
	    cb.containerObj.height(cb.containerObj.parent().height())
	}
    }
}

new CitedBy($('script[src="citedby.jq.src.js"]')).start()