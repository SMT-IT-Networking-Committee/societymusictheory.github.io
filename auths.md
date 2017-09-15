---
title: All papers
layout: default
---

<!--
    this sorts by key, which is not-quite-alphabetical. That can be fixed
    later.
-->

{% for paper in site.data.papers %}
{% assign p = paper[1] %}
{% assign auths = p.authors | map: "name" %}
* {{ auths | array_to_sentence_string }} -- {{ p.title }}
{% endfor %}
