base:
  '*':
    - users
    - users.{{ grains['environment'] }}
    - users.ssh-keys