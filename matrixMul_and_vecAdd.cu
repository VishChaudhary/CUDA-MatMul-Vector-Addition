#include "stdio.h"
#include "math.h"

__global__ void vecAdd(float* a,float *b, float *c, int n){
  int i = blockDim.x * blockIdx.x + threadIdx.x;
  if(i<n){
    c[i] = a[i] + b[i];
  }
  if(i==50){
    printf("GPU working, i=50\n");
  }
}
//multiplies two square matricies together 
__global__ void MatrixMulKernel(float* M, float* N, float* P, int width){
  int col = blockIdx.x * blockDim.x + threadIdx.x;
  int row = blockIdx.y * blockDim.y + threadIdx.y;

  if((row<width) & (col < width)){
    float Pvalue = 0;
    for(int k =0; k<width; ++k){
      Pvalue += M[row*width+k] * N[k*row+col];
    }
    P[row*Width+col] = Pvalue;
  }
}


int main(){

  int n = 10000;

  size_t bytes = n * sizeof(float);

  float *a_h = (float*)malloc(bytes);
  float *b_h = (float*)malloc(bytes);
  float *c_h = (float*)malloc(bytes);

  float *a_d, *b_d, *c_d;

  cudaMalloc(&a_d, bytes);
  cudaMalloc(&b_d, bytes);
  cudaMalloc(&c_d, bytes);

  for(int i=0; i<n; i++){
    a_h[i] = sin(i) + cos(i);
    b_h[i] = cos(i)*sin(i);
  }

  cudaMemcpy(a_d, a_h,bytes, cudaMemcpyHostToDevice);
  cudaMemcpy(b_d, b_h,bytes, cudaMemcpyHostToDevice);

  //createMat<<<ceil(n/256.0), 256>>>(a_d,b_d,c_d, n);
  vecAdd<<<ceil(n/256.0), 256>>>(a_d,b_d,c_d,n);
  cudaMemcpy(c_h,c_d, bytes, cudaMemcpyDeviceToHost);
  printf("%f",c_h[5]);

  free(a_h);
  free(b_h);
  free(c_h);

  cudaFree(a_d);
  cudaFree(b_d);
  cudaFree(c_d);

  return 0;
}


