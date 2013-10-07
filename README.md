Using color compatibility for assessing image realism
------------------------

This software package implements the algorithms presented in our ICCV 2007 paper:

J.-F. Lalonde and A. A. Efros. Using color compatibility for assessing image 
realism. In IEEE International Conference on Computer Vision, October 2007.

It implements both the realism assessment (Sec. 3-4-5) and recoloring (Sec. 6)
algorithms. 

Please note that most of the code included herein is not actually used anywhere, 
and was developed as part of the research. I'm including it for completeness. 
Please refer to the demo/demoColorCompatibility.m file as a starting point to 
understand what is being called, and how. 

Getting started
---------------

1. Download 'utils' package and VLfeat (see below);
2. Download the compressed database information and extract into demo/data (see below); 
3. Edit 'getPathName' and modify path to match your local machine.
4. Run 'setPath', make sure there are no errors or warnings. 
5. Run 'demoColorCompatibility'.


Compressed database
-------------------

Download the compressed database information at

http://balaton.graphics.cs.cmu.edu/jlalonde/colorStatistics/db.zip

Extract the .zip file (which should contain a 'db' directory) into the demo/data 
directory. The demo code expects it there. 

The 'db' directory contains the following information:
- concatHisto (and concatHistoTextons): concatenanted color and texton histograms
  for each image in the database. Used to compute the global realism measure. 
- objectDb: large struct array containing information for each object/background
  pair in the database. Used to retrieve the image corresponding to each pair. 


Compiled code
-------------

Make sure to compile (mex):

BruteSearchMex:
  cd 3rd_party/nearestneighbor; mex BruteSearchMex.cpp;

EMD:
  cd 3rd_party/emd; emd_mex;


Utils
-----

Don't forget to download the "utils" code, available at:

https://github.com/jflalonde/utils

Also, the re-coloring code requires VLFeat, available at: 

http://www.vlfeat.org/

Version 0.9.14 was used to test this code. 


Image database
--------------

Right now, the image database is accessible through the webserver:
http://balaton.graphics.cs.cmu.edu/jlalonde/colorStatistics/Images

If you are interested in obtaining the image database (it's basically a scaled-down
version of a subset of LabelMe), send me an email and I'll put a .zip file
online for you to download).

