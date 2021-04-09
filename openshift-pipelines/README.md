# OpenShift Pipelines

[OpenShift Pipelines](https://www.openshift.com/learn/topics/pipelines) enables pipelines on OpenShift based on Red Hat's implementation of [Tekton](https://tekton.dev)
 
### Folders
There is one main folder in the OpenShift Pipelines component
1. cluster: contains the subscription to the OpenShift Pipelines operator


### Installation
To install OpenShift Pipelines add the following to the `kfctl` yaml file.

```
  - kustomizeConfig:
      parameters:
        - name: namespace
          value: openshift-operators
      repoRef:
        name: manifests
        path: openshift-pipelines/cluster
    name: openshift-pipelines
```

### Example
1. Create a Task that can be included in a Pipeline step
   ```
   apiVersion: tekton.dev/v1beta1
   kind: Task
   metadata:
     name: hello-world
   spec:
     params:
       - name: subject
         description: name of person to greet
         default: ODH
         type: string
     steps:
       - name: hello-world
         image: registry.access.redhat.com/ubi8/ubi
         command:
           - echo
         args:
           - "$(params.subject), Hello World!"
   ```

1. Create the Pipeline that will include the hello-world task created above
   ```
   apiVersion: tekton.dev/v1beta1
   kind: Pipeline
   metadata:
     name: hello-world
   spec:
     tasks:
       - name: hello-world
         params:
           - name: subject
             value: ODH Test
         taskRef:
           kind: Task
           name: hello-world
   ```

1. Finally instantiate the pipeline by creating a PipelineRun.
   ```
   apiVersion: tekton.dev/v1beta1
   kind: PipelineRun
   metadata:
     generateName: hello-world-
   spec:
     pipelineRef:
       name: hello-world
   ```
