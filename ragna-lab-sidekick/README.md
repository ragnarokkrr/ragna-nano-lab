Provisioning of Raspberry Pi 3 fleet
====================================

Raspberri Pi fleet could be used for lightweight CI/CD and Dashboarding

- playbooks for Raspberry Pi provisioning
- uses ubuntu server 24.04.2 LTS
- Lubuntu installed on top of ubuntu server but not included in the auto initialization
- ansible and ssh support added
- ansible playbook for building a docker swarm cluster
- ansible playbook for install a docker swarm cluster
- ansible playbook for provision Gitea + Woodpecker CI
- Dashboarding via Prometheus/Graphana