from kubernetes.client import V1Capabilities, V1SELinuxOptions
spawner = c.OpenShiftSpawner
def mcs_selinux_profile(spawner, pod):
  # Apply profile from singleuser-profiles
  apply_pod_profile(spawner, pod)
  if spawner.gpu_mode and spawner.gpu_mode == "selinux" and \
       spawner.extra_resource_limits and "nvidia.com/gpu" in spawner.extra_resource_limits:
    # Currently a bug in RHEL Docker 1.13 whereby /dev IPC dirs get inconsistent MCS
    pod.spec.security_context.se_linux_options = V1SELinuxOptions(type='nvidia_container_t',level='s0')
  return pod
spawner.modify_pod_hook = mcs_selinux_profile
