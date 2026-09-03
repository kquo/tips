---
title: Timeline
---
## Timeline

Reflective entries grouped by the decade their ideas first took hold. An entry joins this page when it declares an era.

{% assign dated = site.pages | where_exp: "p", "p.era" %}
{% assign eras = dated | group_by: "era" | sort: "name" %}
{% if eras.size == 0 %}
No entry has declared an era yet.
{% endif %}
{% for e in eras %}
### {{ e.name }}
{% for p in e.items %}
- [{{ p.title | default: p.name }}]({{ p.url | relative_url }})
{% endfor %}
{% endfor %}
