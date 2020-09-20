## CNS

This code implements the proposed salient object detection algorithm in the following paper:

 - **Jing Lou**, Huan Wang, Longtao Chen, Fenglei Xu, Qingyuan Xia, Wei Zhu, Mingwu Ren, "Exploiting Color Name Space for Salient Object Detection," *Multimedia Tools and Applications*, vol. 79, no. 15, pp. 10873-10897, 2020. doi:10.1007/s11042-019-07970-x

 - Project page: [http://www.loujing.com/cns-sod/](http://www.loujing.com/cns-sod/)
 - The zipped file of the developed MATLAB code can be directly downloaded: [CNS.zip](https://raw.githubusercontent.com/jinglou/p2019-cns-sod/master/CNS.zip).

Copyright (C) 2020 [Jing Lou (楼竞)](http://www.loujing.com/)

Date: Sep 20, 2020


### Notes:

 1. This algorithm can be run in a row by the command:
 	```matlab
    >> Demo
	```

 2. This algorithm reads the input images from the folder `<images>` and generates the resultant saliency maps in the folder `<SalMaps>`.

 3. We have noted that different versions of MATLAB have substantial influences on the results. In our experiments, the code is run in **MATLAB R2014b** (version 8.4).
