# CUDA Build Chain

This overlay contains CUDA build chain to produce CUDA based images for TensorFlow, PyTorch, and Minimal jupyter notebooks.

## Version Details:

```
notebook = ">=6.0.2"
jupyterhub = ">=1.3"
jupyterlab = ">=3.0.0"

TensorFlow: v2.4.1
PyTorch: v1.8.0

CUDA: 11.0.3
```
## Build Details:

- [CUDA-ubi8-build-chain](./cuda-ubi8-build-chain.yaml): This yaml contains CUDA build chain which creates the base image which is used by the jupyter notebook images. 

- [gpu-notebook](./gpu-notebook.yaml): This yaml contains CUDA build chain which creates the GPU supported jupyter notebook images like s2i-minimal-gpu-notebook, s2i-tensorflow-gpu-notebook, and  s2i-pytorch-gpu-notebook.

## Resource Requirements:

**_NOTE:_** If users don't have quota restrictions then they can remove the resource requirements from the [gpu-notebook](./gpu-notebook.yaml)

### Minimal GPU Notebook

The Minimal notebook requires atleast **3GB** of memory while build-time as the minimal notebook installs `jupyterhub`, `jupyterlab` and `jupyter notebook` packages along with the supported extension that requires this much amount of memory.  
we have added **4GB** generously to avoid issues.

### TensorFlow GPU Notebook

The TensorFlow notebook requires atleast **6GB** of memory while build-time as the TensorFlow notebook installs `jupyterlab` and `jupyter notebook` supported extension and `jupyterlab build` requires this much  amount of memory.  
we have added **6GB** generously to avoid issues.

### PyTorch GPU Notebook

The PyTorch notebook requires atleast **6GB** of memory while build-time as the PyTorch notebook installs `jupyterlab` and `jupyter notebook` supported extension and `jupyterlab build` requires this much  amount of memory.  
we have added **6GB** generously to avoid issues.
