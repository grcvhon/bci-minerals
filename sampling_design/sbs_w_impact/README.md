## Spatially-balanced sampling design with impact

In this version, we incorporate the dredge and spoil areas of the BCI Minerals Project when coming up with a spatially balanced sampling design. Details about these areas are available via the [Mardie Project
Dredge and Spoil Disposal Management Plan](https://www.epa.wa.gov.au/sites/default/files/Referral_Documentation/Att3_DSDMP%20%28O2%20Marine%2C%202025%29.pdf) (pp. 10,11).

We think that it is important to assess the levels of sea snake diversity and/or abundance before and after dredging and dumping of spoil. Therefore, we will incorporate these areas into our sampling design. Since we want to explicitly have transect lines within these identified areas, we will add them manually after we have generated our spatially balanced sampling design.

We manually determined the transect lines for the dredge and spoil areas to allow specific positions of the transect lines for these areas. Once satisfied with the locations of the transects for these areas, we incorporated them into our custom function (`sbs_mardie`) to automate the entire process (see function script [here](https://github.com/grcvhon/bci-minerals/blob/main/sampling_design/fn_sbs_mardie.R)). We also reduced the extent to be just north of the spoil grounds.

The revised design is presented below:
```r
sbs_mardie(seed = 909,          # iteration ID
            n_block = 20,       # total number of blocks (squares) that will have transect lines
            block_size = 1000,  # length of each side of the square (in metres)
            n_trns = 60,        # total number of transects across total number of blocks 
                                # (here, 60 transects across 20 blocks = 3 transects/block)

            # Adjusted extent of map (ymax modified)
            xmin = 115.61768, 
            xmax = 116.12871, 
            ymin = -21.35492, 
            ymax = -20.8176 
```
<p align = "center">
<img src="https://raw.githubusercontent.com/grcvhon/bci-minerals/main/misc/909_w_impact_legend.png", width = 100%, height = 100%>
<div align = "center">
<sup>Spatially-balanced sampling design with impact zones identified. Survey design as of 21 October 2025.</sup>
</div>
</p>

[Return to main](https://github.com/grcvhon/bci-minerals)