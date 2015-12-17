{% set codename = 'previous' %}
{% set revision = '2015.5' %}
{% set outdir = '2015.5' %}

checkout_repo_{{ codename }}:
  git.latest:
    - name: https://github.com/saltstack/salt.git
    - rev: {{ revision }}
    - target: /var/salt/{{ outdir }}

build_docs_{{ codename }}:
  environ.setenv:
    - name: SALT_ON_SALTSTACK
    - value: "true"
  cmd.run:
    - name: make html | ts '%F (%a) %T %Z:' > /var/salt/{{ codename }}.log.txt 2>&1
    - cwd: /var/salt/{{ outdir }}/doc

copy_log_file_{{ codename }}:
  file.copy:
    - name: /var/salt/{{ outdir }}/doc/_build/html/log.txt
    - source: /var/salt/{{ codename }}.log.txt
    - force: True

remove_sources_{{ codename }}:
  file.absent:
    - name: /var/salt/{{ outdir }}/doc/_build/html/_sources

copy_404_{{ codename }}:
  file.copy:
    - name: /var/salt/{{ outdir }}/doc/_build/html/404.html
    - source: /var/salt/files/{{ outdir }}/404.html
    - force: True

copy_htaccess_{{ codename }}:
  file.copy:
    - name: /var/salt/{{ outdir }}/doc/_build/html/.htaccess
    - source: /var/salt/files/{{ outdir }}/.htaccess
    - force: True

sftp_docs_{{ codename }}:
  cmd.run:
    - name: lftp -c "open -u {{pillar['ftpusername']}},{{pillar['ftppassword']}}
           -p 2222 sftp://saltstackdocs.wpengine.com;mirror -c --reverse --delete --use-cache
           /var/salt/{{ outdir }}/doc/_build/html /en/{{ outdir }}"

