#add sudo users

{% for user, args in pillar.get('all', {}).iteritems() %}

{% for sudo in pillar.get('sudo-users')  %}
{% if sudo  == user %}
sudo {{user}}:
  user.present:
    - name: {{ user }}
    - fullname: {{ args['fullname'] }}
    - home: /home/{{ user }}
    - groups:
        - sudo

sudo {{user}}_key:
  ssh_auth.present:
    - user: {{ user }}
    - name: {{ args['ssh-keys']}}

{% endif %}
{% endfor %}


# Add users


{% for users in salt['pillar.get']('k8s:node:abc:env-users')  %}
{% if users == user %}
normal {{user}}:
  user.present:
    - name: {{ user }}
    - fullname: {{ args['fullname'] }}
    - home: /home/{{ user }}


{{user}}_key:
  ssh_auth.present:
    - user: {{user}}
    - name: {{ args['ssh-keys']}}
{% endif %}
{% endfor %}



  #remove users
{% for users in pillar.get('removed-users')  %}
{% if users == user %}

remove {{user}}:
  user.absent: {{user}}
  group.absent: {{user}}


{{user}}_root_key:
  ssh_auth.absent:
    - user: root
    - name: {{ args['ssh-keys']}}

remove-{{user}}_key:
  ssh_auth.absent:
    - user: {{user}}
    - name: {{ args['ssh-keys']}}
  {% endif %}
  {% endfor %}

#remove sudo access

{% for users in pillar.get('no-sudo-users')  %}
{% if users == user %}

remove sudo access {{user}}:
  group.present:
    - name: sudo
    - delusers:
        - {{user}}


{{user}}_root_key:
  ssh_auth.absent:
    - user: root
    - name: {{ args['ssh-keys']}}

{% endif %}
{% endfor %}

{% endfor %}

# Allow sudoers to sudo without passwords.
# This is to avoid having to manage passwords in addition to keys
/etc/sudoers.d/sudonopasswd:
  file.managed:
    - source: salt://salt/users/files/sudoers.d/sudonopasswd
    - user: root
    - group: root
    - mode: 440
