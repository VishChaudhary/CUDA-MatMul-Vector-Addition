#include "stdio.h"
#include "math.h"

__device__ void vecAdd(double* a,double *b, double *c, int n){
  int i = blockDim.x * blockIdx.x + threadIdx.x;
  if(i<n){
    c[i] = a[i] + b[i];
  }
}

__global__ void createMat(double* a,double *b,double*c, int n){
  int i = blockIdx.x * blockDim.x + threadIdx.x;
  if(i<n){
    a[i] = sin(i) + cos(i);
    b[i] = cos(i)*sin(i);
  }
  vecAdd<<<ceil(n/256.0), 256>>>(a,b,c,n);
}



int main(){

int n = 10000;

int bytes = n * sizeof(double);

double *a_h = (double*)malloc(bytes);
double *b_h = (double*)malloc(bytes);
double *c_h = (double*)malloc(bytes);

double *a_d, b_d, c_d;

cudaMalloc(&a_d, bytes);
cudaMalloc(&b_d, bytes);
cudaMalloc(&c_d, bytes);

cudaMemcpy(a_d, a_h,bytes, cudaMemcpyHostToDevice);
cudaMemcpy(b_d, b_h,bytes, cudaMemcpyHostToDevice);

createMat<<<ceil(n/256.0), 256>>>(a_d,b_d,c_d, n);

cudaMemcpy(c_h,c_d, bytes, cudaMemcpyDeviceToHost);

free(a_h);
free(b_h);
free(c_h);

cudaFree(a_d);
cudaFree(b_d);
cudaFree(c_d);

return 0;
}


