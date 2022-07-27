# Visual Analytics Software for Discovering Structural Groups in Complex Networks

Copyright (C) 2011  Takashi Nishikawa
 
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA. 

The full text of the GNU General Public License can be found in the file "License.txt".  Additional copyright notes can be found in the file "Copyright.txt".


## What the software does

This software allows you to choose from a set of networks and apply the method of finding structural groups, which is described in the paper

T. Nishikawa and A. E. Motter, Discovering Network Structure Beyond Communities, Scientific Reports (in press).

Original sources for the data for the available networks can be found in "Copyright.txt".  More detailed description can be found in the above referenced paper.

If you are interested in applying the method to your own network dataset, please contact us (see contact info below) for a version of the software with full functionality.


## How to run the software

Extract all files from the downloaded zip file.  This should create a directory named "find_struct_groups".  To run the software from within Matlab, just change the current directory to this directory and type

find_struct_groups

If you prefer to run it from a different directory, you can simply move the whole directory to anywhere you wish; just make sure to include the directory in the Matlab search path.


## Troubleshooting

If the software stops with the error "Undefined function or method 'clustering_coefficients_mex' for...", the version of the MatlabBGL toolbox included in this software may not be suitable for your computer.  Please visit 

http://www.mathworks.com/matlabcentral/fileexchange/10922

and try downloading and installing an appropriate version.  The newly installed directory "matlab_bgl" should replace the one with the same name in the directory "find_struct_groups".
