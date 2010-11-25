function CitedBy(elementIdOrNode, additional) {

    this.queryUrlFragment = "http://localhost/"
    this.abortTimeout = 15 * 1000
    this.parentNode = undefined
    this.doi = undefined
    this.onSuccess = undefined
    this.onFailure = undefined

    CitedBy.prototype.start = function() {
	if (additional) {
	    this.onSuccess = additional.onSuccess
	    this.onFailure = additional.onFailure
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
	req.onreadystatechange = function(r) {
	    if (req.readyState == 4) {
		if (r.responseText) {
		    cb.fillWithResponse(r.responseText)
		} else {
		    cb.fillWithFailure('Error: CrossRef Cited-by query response is empty.')
		}
	    }
	}

	req.send()

	window.setTimeout(function() {
	    if (req.readyState != 4) {
		req.abort()
		cb.fillWithFailure('Error: CrossRef Cited-by query is not responding.')
	    }
	}, this.abortTimeout)
    }

    CitedBy.prototype.fillWithResponse = function(responseData) {
	if (responseData.error) {
	    this.fillWithFailure(responseData.error)
	} else {
	    var citationsHtml = ''

	    if (responseData.citations.length == 0) {
		citationsHtml = (
		    '<div class="citedby-none">' +
		    'There are no CrossRef Cited-by links for this article.' +
		    '</div>'
		)
	    } else {
	        var citationsHtml = '<div class="citedby-citation">'

		for (var c in responseData.citations) {
		    citationsHtml += (
			'<span class="citedby-title">' + c.title + '</span>' +
			'<span class="citedby-authors">' + c.authors + '</span>' +
			'<span class="citedby-year">' + c.year + '</span>' +
			'<span class="citedby-journal-title">' + 
                            c.journal_title + 
                        '</span>' +
			'<a class="citedby-doi" href="http://dx.doi.org/' + c.doi + '">' + 
			    c.doi +
			'</a>'
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
    	this.parentNode.innerHTML = '<div class="citedby-error">' + message + '</div>'
	
    	if (this.onFailure) {
    	    this.onFailure()
    	}
    }
    
    this.start()
}

/* A munged, cross-browser XMLHttpRequest wrapper. */
(function(m,u,n,g,e,d){for(g=u[d[31]]-1;g>=0;g--)n+=e[d[67]][d[72]](u[d[73]](g)-1);u=n[d[71]](' ');for(g=u[d[31]]-1;g>=0;g--)m=m[d[70]](e[d[69]](g%10+(e[d[67]][d[72]](122-e[d[68]][d[74]](g/10))),'g'),u[g]);e[d[3]]('_','$',m)(d,d[46])})("(9z 2w{8y u=6x7x128x;8y b=7w6x7x238x,c=6x7x268x7x168x3w!6x7x438x,d=c3w6x7x348x7x638x7x338x(/MSIE ([\\.0-9]+)/)3wRegExp.$16w7;9z f2w{5x.f=u3w!d?2y u:2y 6x7x08x(_[7]);5x.e=0w};0y(b3wu7x658x)f7x658x=u7x658x;f7x98x=0;f7x88x=1;f7x48x=2;f7x58x=3;f7x28x=4;f9x7x488x=f7x98x;f9x7x518x='';f9x7x528x=2x;f9x7x578x=0;f9x7x588x='';f9x7x398x=2x;f7x398x=2x;f7x388x=2x;f7x408x=2x;f7x378x=2x;f9x7x428x=9z(v,z,a,A,x){6z 5x.d;0y(4x7x318x<3)a=3x;5x.c=a;8y t=5x,n=5x7x488x,j;0y(c3wa){j=9z2w{0y(n9wf7x28x){g(t);t7x148x2w}};6x7x208x(_[41],j)}0y(f7x388x)f7x388x7x188x(5x,4x);0y(4x7x318x>4)5x.f7x428x(v,z,a,A,x);7z 0y(4x7x318x>3)5x.f7x428x(v,z,a,A);7z 5x.f7x428x(v,z,a);0y(!b3w!c){5x7x488x=f7x88x;k(5x)}5x.f7x398x=9z2w{0y(b3w!a)3y;t7x488x=t.f7x488x;l(t);0y(t.b){t7x488x=f7x98x;3y}0y(t7x488x6wf7x28x){g(t);0y(c3wa)6x7x248x(_[41],j)}0y(n9wt7x488x)k(t);n=t7x488x}};f9x7x538x=9z(C){0y(f7x408x)f7x408x7x188x(5x,4x);0y(C3wC7x358x){C=6x7x138x?2y 6x7x138x2w7x548x(C):C7x668x;0y(!5x.d7x18x)5x.f7x558x(_[1],_[17])}5x.f7x538x(C);0y(b3w!5x.c){5x7x488x=f7x88x;l(5x);9y(5x7x488x<f7x28x){5x7x488x2v;k(5x);0y(5x.b)3y}}};f9x7x148x=9z2w{0y(f7x378x)f7x378x7x188x(5x,4x);0y(5x7x488x>f7x98x)5x.b=3x;5x.f7x148x2w;g(5x)};f9x7x288x=9z2w{3y 5x.f7x288x2w};f9x7x298x=9z(w){3y 5x.f7x298x(w)};f9x7x558x=9z(w,B){0y(!5x.d)5x.d=1w;5x.d[w]=B;3y 5x.f7x558x(w,B)};f9x7x158x=9z(w,i,e){8z(8y m=0,s;s=5x.e[m];m2v)0y(s[0]6ww3ws[1]6wi3ws[2]6we)3y;5x.e7x478x([w,i,e])};f9x7x508x=9z(w,i,e){8z(8y m=0,s;s=5x.e[m];m2v)0y(s[0]6ww3ws[1]6wi3ws[2]6we)1z;0y(s)5x.e7x568x(m,1)};f9x7x258x=9z(q){8y r={'type':q7x628x,'target':5x,'currentTarget':5x,'eventPhase':2,'bubbles':q7x218x,'cancelable':q7x228x,'timeStamp':q7x608x,'stopPropagation':9z2w1w,'preventDefault':9z2w1w,'0zitEvent':9z2w1w};0y(r7x628x6w_[49]3w5x7x398x)(5x7x398x7x308x4w5x7x398x)7x188x(5x,[r]);8z(8y m=0,s;s=5x.e[m];m2v)0y(s[0]6wr7x628x3w!s[2])(s[1]7x308x4ws[1])7x188x(5x,[r])};f9x7x618x=9z2w{3y '['+_[36]+' '+_[12]+']'};f7x618x=9z2w{3y '['+_[12]+']'};9z k(t){0y(f7x398x)f7x398x7x188x(t);t7x258x({'type':_[49],'bubbles':1x,'cancelable':1x,'timeStamp':2y Date+0})};9z h(t){8y p=t7x528x,y=t7x518x;0y(c3wy3wp3w!p7x278x3wt7x298x(_[1])7x338x(/[^\\/]+\\/[^\\+]+\\+xml/)){p=2y 6x7x08x(_[6]);p7x198x=1x;p7x648x=1x;p7x328x(y)}0y(p)0y((c3wp7x448x9w0)4w!p7x278x4w(p7x278x3wp7x278x7x598x6w_[45]))3y 2x;3y p};9z l(t){7y{t7x518x=t.f7x518x}3z(e)1w7y{t7x528x=h(t.f)}3z(e)1w7y{t7x578x=t.f7x578x}3z(e)1w7y{t7x588x=t.f7x588x}3z(e)1w};9z g(t){t.f7x398x=2y 6x7x38x};0y(!6x7x38x9x7x188x){6x7x38x9x7x188x=9z(t,o){0y(!o)o=0w;t.a=5x;t.a(o[0],o[1],o[2],o[3],o[4]);6z t.a}};6x7x128x=f})2w;",">?!>=!..!,,!>.!>,!>\"!>>\"!\"\"!>>!>>>!}}!\'\'!*)!~|!^\\!^%\\!^^!\\`\\!xpeojx!tjiu!tuofnvhsb!fvsu!mmvo!ftmbg!iujx!fmjix!sbw!zsu!idujxt!gpfqzu!xpsiu!osvufs!xfo!gpfdobutoj!gj!opjudovg!spg!ftmf!fufmfe!umvbgfe!fvojuopd!idubd!ftbd!lbfsc!oj",'',0,this,'ActiveXObject Content-Type DONE Function HEADERS_RECEIVED LOADING Microsoft.XMLDOM Microsoft.XMLHTTP OPENED UNSENT XMLDOM XMLHTTP XMLHttpRequest XMLSerializer abort addEventListener all application/xml apply async attachEvent bubbles cancelable controllers detachEvent dispatchEvent document documentElement getAllResponseHeaders getResponseHeader handleEvent length loadXML match navigator nodeType object onabort onopen onreadystatechange onsend onunload open opera parseError parsererror prototype push readyState readystatechange removeEventListener responseText responseXML send serializeToString setRequestHeader splice status statusText tagName timeStamp toString type userAgent validateOnParse wrapped xml String Math RegExp replace split fromCharCode charCodeAt floor'.split(' '))