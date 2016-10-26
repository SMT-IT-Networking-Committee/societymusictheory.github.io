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
        linkHandouts = function(idx, elem) {
            var key = getKey(elem),
                filename = SMT.handoutList[key],
                href;

            if (!filename) { return; }

            href = '//societymusictheory.org/files/2016_handouts/' + filename;
            $(elem).append('&emsp;<a href="'+href+'"><i class="fa fa-file"></i></i>');
        },
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
        };

    $('p.author').each(linkHandouts);
    $('li').each(linkHandouts);
};
