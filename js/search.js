---
  # oh jekyll, you are so weird and so effective
---

// Dumb, but effective. -- michael, 2017-10-30
var SMT = SMT || {};
SMT.search = {};

SMT.search.paperLookup = {
{%- for session in site.data.sessions -%}
  {%- assign sess = session[1] -%}
  {%- for p in sess.papers -%}
    {{- p | jsonify -}}:{{- sess.link | jsonify -}},
  {%- endfor -%}
{%- endfor -%}
};

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
{"title":{{p.title | jsonify }},"abstract":{{p.abstract | strip_html | jsonify }},"authors":{{ auth | jsonify }},"link":{{ p.link | jsonify }},"key":{{ paper[0] | jsonify }}},
{% endfor %}
];

SMT.search.store = {};

SMT.search.index = lunr(function () {
  this.field('title');
  this.field('authors');
  this.field('abstract');
  this.ref('key');

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
});

$(document).ready(function() {
  $('input#search-box').on('keyup', function () {
    var resultdiv = $('#search-results'),
        query = $(this).val(),
        result = SMT.search.index.search(query);

    resultdiv.empty();

    for (var item in result) {
      var ref = result[item].ref,
          obj = SMT.search.store[ref],
          sesslink = SMT.search.paperLookup[ref];

      var out = '<div class="result">';
      out += '<p>' + obj.authors + " • " + obj.title;
      out += sesslink ? '<br><a href="' + sesslink + '">Go to paper</a>' : '' ;
      out += '</p></div>';
      resultdiv.append(out);
    }
  });

  $('form#search').on('submit', function () { return false });
});
