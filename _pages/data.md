---
layout: archive
title: ""
permalink: /data/
author_profile: true
---

<style>
h2.data-section {
  margin-top: 0 !important;
  padding-top: 0 !important;
}

h2.archive__item-title {
  font-size: 0.8em !important;
  font-weight: 400 !important;
  text-decoration: none;
}

a.archive__item-title-link {
  color: #000 !important;
}

a.archive__item-title-link:hover {
  color: #2f7f93 !important;
}
</style>

<div style="max-width: 78%;">
<h2 class="data-section" style="font-size: 0.9em; font-weight: 400; border: none; padding-bottom: 0;">REPLICATION DATASETS</h2><hr />

<p style="font-size: 0.75em;">For replication datasets and their associated code, please refer to the specific publication on the <a href="/publications/" style="color: #2f7f93;">Publications</a> Page.</p>

<div style="margin-top: 3em;"></div>

<h2 class="data-section" style="font-size: 0.9em; font-weight: 400; border: none; padding-bottom: 0;">NEW DATASETS</h2><hr />

<div style="margin-top: 3em;"></div>

<h2 class="data-section" style="font-size: 0.9em; font-weight: 400; border: none; padding-bottom: 0;">EXTERNAL DATASETS</h2><hr />

<p style="font-size: 0.75em;">Below you can find a curated selection of links to datasets created by other researchers, teams or organizations, some of which I have used in my research. As external sources, their creators are responsible for the content and its availability.</p>
</div>

{% for post in site.datasets reversed %}
  {% include archive-single.html %}
{% endfor %}
