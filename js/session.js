Zepto(function($) {

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
        abstractTitles[i].id = genId
        $(titles[i]).wrapInner('<a href="#'+ genId + '"></a>');
    }
});
