# Set up Monitoring

## Installation

Once the cluster admins have installed the Prometheus operator and provided the requisite permissions to the admins, you can run the following commands.

```bash
oc create serviceaccount aicoe-prometheus
oc create -f psi-ocp.yaml
```

## Adding New Namespaces for Prometheus to Monitor

**NOTE:** Steps 1 and 2 require cluster admin permissions.

1. Make sure that MultiNamespace install is set to true

    ```yaml
    installModes:
        - supported: true
          type: OwnNamespace
        - supported: true
          type: SingleNamespace
        - supported: false
          type: MultiNamespace
        - supported: false
          type: AllNamespaces
    ```

2. Make sure that `targetNamespaces` in the Prometheus Operator Group has your namespace

    ```yaml
    spec:
      targetNamespaces:
        - dh-psi-monitoring
        - aicoe-argocd
        - <new_target_namespace>
    ```

3. Give the prometheus service account access to your namespace

    ```bash
    oc project <target_namespace>
    oc policy add-role-to-user view system:serviceaccount:dh-psi-monitoring:aicoe-monitoring
    ```

4. Make sure that the Prometheus CR has a label that matches a label for the target namespace:
This namespace selector can be found at [psi-ocp.yaml](https://github.com/AICoE/aicoe-sre/blob/master/monitoring/prometheus/psi-ocp.yaml#L16)

    ```yaml
    serviceMonitorNamespaceSelector:
      matchLabels:
        <target_namespace_label_key>: <target_namespace_label_value>
    ```

    This label needs to be part of the namespace spec. You can find the namespace labels by running the following command

    ```bash
    oc get project <target_namespace> -o yaml
    ```

## Alerting

### Alertmanager Config

The alertmanager deployment will fail unless there is a secret in the namespace called `alertmanager-<alertmanager_name>`.
You can create this secret by running the following command:

```bash
kubectl create secret generic alertmanager-<alertmanager-name> --from-file=alertmanager.yaml
```

A `alertmanager.yaml` can look at the following:

```yaml
global:
  smtp_smarthost: '<mail_server>'
  smtp_from: '<alert_host_email>'
  smtp_auth_username: 'bar'
  smtp_auth_password: 'foo'
  smtp_require_tls: false
  resolve_timeout: 5m
route:
  group_by: ['job']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 12h
  receiver: 'developer-mails'
receivers:
- name: 'developer-mails'
  email_configs:
    - to: '<email_list>'
      send_resolved: true
```

The following user-guide can be a good point of reference: [alerting.md](https://github.com/coreos/prometheus-operator/blob/master/Documentation/user-guides/alerting.md)

## Common issues

### Prometheus unable to detect pod/service monitors

Make sure that the monitor has the `prometheus: dh-monitoring` label on it.
