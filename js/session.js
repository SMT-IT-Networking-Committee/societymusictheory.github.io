var SMT = {};

Zepto(function($) {
    SMT.linkAbstracts($);
    SMT.linkHandouts($);
});

SMT.linkAbstracts = function($) {
    var titles = $('p.title'),
        abstractTitles = $('p.abs-title'),
        num = titles.length,
        i, genId;

    // link room number
    $('span.room').first().wrapInner('<a href="../../../maps/"></a>');

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
    $('p.author').each(function(_, elem) {
        // Get author last name as lowercase.
        // NB: This only gets the first author's name, and doesn't work if there
        // are non-ASCII characters. There are few enough of those that we can
        // special-case them manually.
        var matches = $(elem).text().match(/\s([A-Za-z\-]+)\s+\(/);
        if (matches !== null && matches[1]) {
            var lcName = matches[1].toLowerCase();

            // TODO: wire up the links here
            if (SMT.handoutList[lcName]) {
                console.log(SMT.handoutList[lcName]);
            }
        }
    });
};
