var SMT = SMT || {};

Zepto(function($) {
    SMT.linkAbstracts($);
    SMT.linkHandouts($);
});

SMT.linkAbstracts = function($) {
    var titles = $('p.title'),
        abstractTitles = $('p.abs-title'),
        num = titles.length,
        i, genId;

    // don't try to link if there are no abstracts
    if (abstractTitles.length === 0) {
        return;
    }

    for (i = 0; i < num; i++) {
        genId = 'abs_' + i;
        if (!abstractTitles[i]) { continue; }
        abstractTitles[i].id = genId
        $(titles[i]).wrapInner('<a href="#'+ genId + '"></a>');
    }
};


SMT.linkHandouts = function($) {
    var titles = $('p.title'),
        getKey = function(elem) {
            var $el = $(elem),
                matches;

            // if data attribute, use that
            if ($el.data('handout')) {
                return $(elem).data('handout');
            }

            // Otherwise, use author last name as lowercase.
            // NB: This only gets the first author's name, and doesn't work if
            // there are non-ASCII characters. There are few enough of those
            // that we can special-case them manually.
            matches = $(elem).text().match(/\s([A-Za-z\-]+)\s+\(/);

            if (matches !== null && matches[1]) {
                return matches[1].toLowerCase();
            }

            return false;
        },
        linkHandout = function(elem, key) {
            var filename = SMT.handoutList[key],
                href;

            // don't try to link if the filename doesn't exist
            if (!filename) { return; }

            href = '//societymusictheory.org/files/2016_handouts/' + filename;
            $(elem).append('&emsp;<a href="'+href+'"><i class="fa fa-file"></i></i>');
        };

    $('p.author').each(function(idx, elem) {
        var key = getKey(elem);
        linkHandout(elem, key);
    });

    // Check lis for data-handout attributes.
    // This is needed for panel discussions when people might not have
    // <p.author> tags.
    $('li').each(function(idx, elem) {
        var key = $(elem).data('handout');
        linkHandout(elem, key);
    });
};
