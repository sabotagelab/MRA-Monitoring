READ ME

Found here is the version of MRA_DT_STL, and supporting files, correspond to the submission
to HSCC 2022. 

Functions included are the following:

create_basis.m
MRA_DT_STL.m
recusive_monitor.m
scalar_interval_prod.m
wavelet_monitor.m
Demo.m

create_basis.m is a function for creating a wavelet basis. It only creates one V_{-j}
or W{-j} at a time. It requires the wavelet toolbox from matlab. 

MRA_DT_STL.m is a function which implements the algorithm MRA-DT-STL from the publication.
It has it's own syntax, different than any of the well known monitoring toolboxes.

recursive_monitor.m is a function to monitor the formulas returned by MRA_DT_STL.m against
decomposed, or low resolution, signals.

scalar_interval_prod.m simply implements interval arithmetic.  

wavelet_monitor.m is a file implementing the application. It is particular about the format
of the inputs so be sure to read that before doing much with it outside of the Demo file.

Also included is a Demo.m, which provides an example utilizing each of the above. 