# MorFishJ to do list

## New features
1. Change all measurements to pixels instead of centimetres to allow analysis of images without reference scale. Start with a dialog with three options:
  - no scale available --> set 'px.cm' = 'NA';
  - reference object --> get the scale as per current analysis but don't set the scale, just save 'px.cm';
  - known length --> new dialog asking for length type (SL or TL), measure, and unit, then save 'px.cm' once the length has been measured in pixels.

2. Automatically create output folders in the raw images' parent directory

3. Save also ROI for rotation and straightening for full reproducibility

4. Add options for unusual morphologies:
  - fish without caudal fin --> CFd = 0; CFs = 0;
  - fish without pectoral fin --> PFl = 0; PFs = 0; PFi = 0; PFb = 0/NA;
  - fish with ventral mouth --> Mo = 0; JL = NA (0 for those with sucker mouth); EMa = 90; EMd = from eye centroid to intersection of K with lower edge of the head;
  - fish with rostrum --> need additional ref line at tip of upper (halfbeaks) or lower jaw (billfishes, paddlefish) to properly measure SL, HL, SnL (NO needlefishes);
  - flatfish --> to be decided.
  
**Be aware of these corrections when computing ratios!**

5. Add a simple macro to ease visualisation of analysed images with ROIs

6. New analysis specific for pectoral fin following Wainwright et al. (2002) (DOI: 10.1023/A:1019671131001)
