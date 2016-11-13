#cloud-config

packages:
 - python
package_upgrade: true

write_files:
- content: |
      {
        "role": "${role}",
        "env": "${env}",
        "availability_zone": "${availability_zone}",
      }
  path: /etc/ansible/facts.d/pressr.fact
