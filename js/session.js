Zepto(function($) {

    var titles = $('p.title'),
        abstractTitles = $('p.abs-title'),
        num = titles.length,
        i, genId;

    for (i = 0; i < num; i++) {
        genId = 'abs_' + i;
        abstractTitles[i].id = genId
        $(titles[i]).wrapInner('<a href="#'+ genId + '"></a>');
    }

    $('span.room').first().wrapInner('<a href="../../../maps/"></a>');

});
