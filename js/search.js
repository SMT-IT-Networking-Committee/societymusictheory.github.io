---
  # oh jekyll, you are so weird and so effective
---

var SMT = SMT || {};
SMT.search = SMT.search || {};
SMT.search.store = {};

SMT.search.sessions = [
{%- for session in site.data.sessions -%}
  {%- assign sess = session[1] -%}
  {%- capture chair -%}
    {%- if sess.chair.formatted -%}
      {{ sess.chair.formatted }}
    {%- else -%}
      {{ sess.chair.name }}
    {%- endif -%}
  {%- endcapture -%}
  {"type": "session","key": {{ sess.slug | jsonify }},"title": {{ sess.title | jsonify }},"link": {{ sess.link | jsonify }},"chair": {{ chair | jsonify }},
    {%- if sess.panelists -%}
      "panelists": {{ sess.panelists | map: "name" | array_to_sentence_string: '' | jsonify }}
    {%- endif -%}
  },
{%- endfor -%}
];

SMT.search.documents = [
{%- for paper in site.data.papers -%}
  {%- assign p = paper[1] -%}
  {%- capture auth -%}
    {%- if p.authors[0].formatted -%}
      {{ p.authors | slice: 1,99 | map: "name" | array_to_sentence_string }}
    {%- else -%}
      {{ p.authors[0].name }}
    {%- endif -%}
  {%- endcapture -%}
{"type":"paper","title":{{p.title | jsonify }},"abstract":{{p.abstract | strip_html | jsonify }},"authors":{{ auth | jsonify }},"link":{{ p.link | jsonify }},"key":{{ paper[0] | jsonify }}},
{% endfor %}

];

SMT.search.documents.forEach(function (doc) {
  SMT.search.store[doc.key] = doc;
});

SMT.search.sessions.forEach(function (doc) {
  SMT.search.store[doc.key] = doc;
})

SMT.search.index = lunr.Index.load(SMT.search.serializedIndex);

SMT.search.paperLookup = {
{%- for session in site.data.sessions -%}
  {%- assign sess = session[1] -%}
  {%- for p in sess.papers -%}
    {{- p | jsonify -}}:{{- sess.link | jsonify -}},
  {%- endfor -%}
{%- endfor -%}
};

$(document).ready(function() {
  $('input#search-box').on('keyup', function () {
    var resultdiv = $('#search-results'),
        query = $(this).val(),
        result = SMT.search.index.search(query);

    resultdiv.empty();

    if (query.length === 0) {
      return;
    }

    for (var item in result) {
      var ref = result[item].ref,
          obj = SMT.search.store[ref],
          type = obj.type,
          sesslink = type === 'paper' ? SMT.search.paperLookup[ref] : obj.link;

      var out = '<div class="result"><p>';

      if (type === 'paper') {
        out += sesslink ? '<div><span class="author">' + obj.authors + '</span></div>' + '<div><a style="font-weight:500;" href="' + sesslink + '">' + obj.title + '</a></div>' : '' ;
        out += '</p></div>';
        resultdiv.append(out);
      } else if (type === 'session') {
        out += sesslink ? '<div><span class="author">' + obj.chair + ', <em>Chair</em></span></div>' + '<div><a style="font-weight:500;" href="' + sesslink + '">Session: ' + obj.title + '</a></div>' : '' ;
        out += '</p></div>';
        resultdiv.prepend(out);
      } else {
        console.warning("unknown result type: " + type);
      }
    }
  });

  $('form#search').on('submit', function () { return false });
});

// This isn't actually called, but can be called from the console to
// regenerate the date in index.js. -- michael, 2018-10-22
SMT.search._generateIndex = function () {
  return lunr(function () {
    this.field('title');
    this.field('authors');
    this.field('abstract');
    this.field('chair');
    this.field('panelists');
    this.ref('key');

    console.log('generating index?');

    var stemBetter = function (builder) {
      var possessive = /'s?$/;
      var pipelineFunction = function (token) {
        if (token.toString().search(possessive) !== -1) {
          return token.update(function () {
            return token.toString().replace(posessive, '');
          });
        } else if (token.toString() == 'Schenkerian') {
          return token.update(function() { return "Schenker" });
        } else {
          return token;
        }
      };

      this.Pipeline.registerFunction(pipelineFunction, 'stemBetter');
      builder.pipeline.before(lunr.stemmer, pipelineFunction);
      builder.searchPipeline.before(lunr.stemmer, pipelineFunction);
    };

    SMT.search.documents.forEach(function (doc) {
      SMT.search.store[doc.key] = doc;
      this.add(doc);
    }, this)

    SMT.search.sessions.forEach(function (doc) {
      SMT.search.store[doc.key] = doc;
      this.add(doc);
    }, this)
  }).toJSON();
};

