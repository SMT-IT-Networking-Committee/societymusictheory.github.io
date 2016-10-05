var SMT = SMT || {};

SMT.index = {
    nodeList: [],       // list of <li> nodes, built on page load
    authList: [],       // list of lower-cased, ascii-ized author names

    // the function to ascii-ize names
    latinize: (function() {
        var translate_re = /[’Ááèéëöóñ]/g;  // special chars here
        var asciiMap = {
            "’": "'", "Á": "A", "á": "a", "è": "e", "é": "e", "ë": "e",
            "ö": "o", "ó": "o", "ñ": "n",
        };
        return function(s) {
            return (s.replace(translate_re,
                              function(match) {return asciiMap[match];}
                             )).toLowerCase();
        }
    }()),
};

SMT.buildIndex = function($) {
    SMT.index.ul = $("ul#author-list");     // store parent <ul> for later

    SMT.index.ul.find("li").each(function(idx, elem) {
        var t = SMT.index.latinize(elem.innerText);
        t = t.replace(" (1, 2)", "");
        SMT.index.nodeList[idx] = elem;
        SMT.index.authList[idx] = t;
    });

    // add helper functions to clear/restore list

    var origList = SMT.index.ul.html();
    SMT.index.restoreList = function() { SMT.index.ul.html(origList)},
    SMT.index.clearList =   function() { SMT.index.ul.html("")};
};

SMT.index.filter = function() {
    var val = $(this).val(),
        found = [],
        i;

    // don't bother filtering until there are more than two characters
    if (val.length <= 2) {
        SMT.index.clearList();
        SMT.index.restoreList();
        return;
    } else {
        val = SMT.index.latinize(val);
    }

    // loop through elements, look for those that match
    for (i = 0; i < SMT.index.authList.length; i++) {
        if (SMT.index.authList[i].search(val) !== -1) {
            found.push(i);
        }
    }

    if (found.length > 0) {
        SMT.index.clearList();
        found.forEach(function(elem) {
            SMT.index.ul.append(SMT.index.nodeList[elem]);
        });
    } else {
        SMT.index.clearList();
        SMT.index.ul.append("<li>Name not found.</li>");
    }

};

// On document load, set up the index and add the input handler
Zepto(function($) {
    SMT.buildIndex($);
    $("input#filterList").on('input', SMT.index.filter);
});
