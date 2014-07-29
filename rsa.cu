#include<cuda.h>
#include<cuda_runtime.h>
#include<device_launch_parameters.h>
#include<stdio.h>
#include<conio.h>

__device__  long long int mod(int base,int exponent,int den)
{
	unsigned int a=(base%den)*(base%den);
	unsigned long long int ret=1;
	float size=(float)exponent/2;
	if(exponent==0)
	{
		return base%den;
	}
	else
	{
		while(1)
		{
			if(size>0.5)
			{
				ret=(ret*a)%den;
				size=size-1.0;
			}
			else if(size==0.5)
			{
			ret=(ret*(base%den))%den;
			break;
			}
			else
			{
				break;
			}
		}
	return ret;
	}
}

__global__ void rsa(int * num,int *key,int *den,unsigned int * result)
{
int i=threadIdx.x;
int temp;

 if(i<3)
 {   
	temp=mod(num[i],*key,*den);
	atomicExch(&result[i],temp);
 }
}

void loadDefaultImage(char *loc_exec)
{

    printf("Reading image: lena.pgm\n");
    const char *image_filename = "lena.pgm";
    char *image_path = sdkFindFilePath(image_filename, loc_exec);

    if (image_path == NULL)
    {
        printf("Failed to read image file: <%s>\n", image_filename);
        exit(EXIT_FAILURE);
    }

    initializeData(image_path);
    free(image_path);
}

 int main()
 {
 int  num[3]={16,5,4};
 int key=5;
 int den=35;
 int devcount;
 cudaGetDeviceCount(&devcount);
 printf("%d CUDA devices found",devcount);
 
 if(devcount>0)
 {
 cudaSetDevice(1);
 printf("\nEnter the 8 digit word:");
 for(int i=0;i<3;i++)
 {
	 printf("\n.");
	 scanf("%d",&num[i]);
 }
 printf("\nEnter key parameter 1:");
 scanf("%d",&key);
 printf("\nEnter key parameter 2:");
 scanf("%d",&den);
 
 int *dev_num,*dev_key,*dev_den;
 unsigned int *dev_res;
 unsigned  int res[3]={1,1,1};
 dim3 grid(1,1,1);
 dim3 block(3,3,1);
 
 cudaMalloc( (void **)&dev_num, 3*sizeof(int));
 cudaMalloc( (void **)&dev_key,sizeof(int));
 cudaMalloc( (void **)&dev_den, sizeof(int));
 cudaMalloc( (void **)&dev_res, 3*sizeof(unsigned int));     



      switch (key)
    {
        case 27:
        case 'q':
        case 'Q':
            printf("Shutting down...\n");
            exit(EXIT_SUCCESS);
            break;

        case '-':
            imageScale -= 0.1f;
            printf("brightness = %4.2f\n", imageScale);
            break;

        case '=':
            imageScale += 0.1f;
            printf("brightness = %4.2f\n", imageScale);
            break;

        case 'i':
        case 'I':
            g_SobelDisplayMode = SOBELDISPLAY_IMAGE;
            sprintf(temp, "CUDA Edge Detection (%s)", filterMode[g_SobelDisplayMode]);
            glutSetWindowTitle(temp);
            break;

        case 's':
        case 'S':
            g_SobelDisplayMode = SOBELDISPLAY_SOBELSHARED;
            sprintf(temp, "CUDA Edge Detection (%s)", filterMode[g_SobelDisplayMode]);
            glutSetWindowTitle(temp);
            break;

        case 't':
        case 'T':
            g_SobelDisplayMode = SOBELDISPLAY_SOBELTEX;
            sprintf(temp, "CUDA Edge Detection (%s)", filterMode[g_SobelDisplayMode]);
            glutSetWindowTitle(temp);
            break;

        default:
            break;
    }
}
 cudaMemcpy(dev_num,num,3*sizeof(int),cudaMemcpyHostToDevice);
 cudaMemcpy(dev_key,&key,sizeof(int),cudaMemcpyHostToDevice);
 cudaMemcpy(dev_den,&den,sizeof(int),cudaMemcpyHostToDevice);
 cudaMemcpy(dev_res,res,3*sizeof(unsigned int),cudaMemcpyHostToDevice);    
 rsa<<<grid,block>>>(dev_num,dev_key,dev_den,dev_res);
cudaMemcpy(res,dev_res,3*sizeof(unsigned int),cudaMemcpyDeviceToHost);
cudaFree(dev_num);
cudaFree(dev_key);
cudaFree(dev_den);
cudaFree(dev_res);
for(int i=0;i<3;i++)
{
	printf("\n%d",res[i]);
}
 }
getch();
 return 0;
 }     
    
 