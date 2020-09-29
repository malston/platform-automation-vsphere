# LDAP Configuration for Concourse

## Setup

* Apply this [operations file](https://github.com/concourse/concourse-bosh-deployment/blob/master/cluster/operations/ldap.yml) to configure [ldap authentication](https://concourse-ci.org/ldap-auth.html):

## Usage

LDAP users and groups can be added to the main team authorization config by setting the following env on the web node:

```sh
CONCOURSE_MAIN_TEAM_LDAP_USER=my-user
CONCOURSE_MAIN_TEAM_LDAP_GROUP=my-group
```

This can be done by applying operation files to the bosh deployment.

* Use this [operations file](https://github.com/concourse/concourse-bosh-deployment/blob/master/cluster/operations/add-main-team-ldap-groups.yml) to configure what ldap groups have admin access to the main team

* Use this [operations file](https://github.com/concourse/concourse-bosh-deployment/blob/master/cluster/operations/add-main-team-ldap-users.yml) to configure what ldap users have admin access to the main team

### User Roles & Permissions

[Admin](https://concourse-ci.org/user-roles.html#concourse-admin) is a special user attribute granted only to [owners](https://concourse-ci.org/user-roles.html#team-owner-role) of the main team.

* Use this [operations file](https://github.com/concourse/concourse-bosh-deployment/blob/master/cluster/operations/add-main-team-auth-config.yml) to configure the other [roles](https://concourse-ci.org/user-roles.html) for the main team:

    ```yaml
    roles:
    - name: member
      ldap:
        users: ["somebody"]
        groups: ["ConcourseUsers"]
    ```

This will assign the `member` role to `somebody` ldap user and all members of the `ConcourseUsers` ldap group.

After you apply these operations and deploy Concourse, you should be able to access the main team pipelines using your ldap credentials.

```sh
fly -t concourse login -n main
```

When prompted, open the URL in the browser and use LDAP credentials to login.
