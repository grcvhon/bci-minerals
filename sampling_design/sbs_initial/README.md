## Spatially-balanced sampling design - initial

We will generate a spatially balanced sampling design across the Mardie region while taking into account indicative sampling sites for the Short-nosed sea snake (<i>Aipyusurus apraefrontalis</i>) as presented in the image below. That is, our design will prioritise these identified sites/will increase their inclusion probability when generating a spatially balanced design. The design is shown below and is discussed in the following.

<p align = "center">
<img src="https://raw.githubusercontent.com/grcvhon/bci-minerals/main/misc/image.png", width = 40.3%, height = 40.3%> <img src="https://raw.githubusercontent.com/grcvhon/bci-minerals/main/misc/seed23_preview.png", width = 43%, height = 43%>
<div align = "center">
<sup>Left: Indicative Short-nosed sea snake sampling sites (Source: Daniella Hanf, O2 Marine); Right: Spatially-balanced sampling design (initial).</sup>
</div>
</p>

Here, "spatially balanced" means that the sampling sites we will place within the survey boundary (approximated from the map above) will most likely yield adequate representative data of the sea snake species occurring within the area including the Short-nosed sea snake. 

To execute this systematic sampling approach, the process will place <i>x</i> number of blocks that each have <i>y</i> number of transect lines. These blocks will be placed within the survey area irrespective of its biotic and abiotic characteristics and will only optimise for spatially balanced sampling coverage. However, as mentioned earlier, we have modified the process so that we can still generate a spatially balanced design while putting more weight on the indicative sampling sites for the Short-nosed sea snake. 

Typically, we generate a 1 km<sup>2</sup>-block containing three 1-km transect lines connected in a zig-zag configuration, starting from one corner of the block. Using a zig-zag formation increases the efficiency of sampling within the block. From experience, a quiet set of transect lines i.e. a block with no snakes takes about 10 minutes to traverse under ideal weather conditions.

We created a custom function (`sbs_mardie`) that will automate the entire process (see function script [here](https://github.com/grcvhon/bci-minerals/blob/main/sampling_design/fn_sbs_mardie.R)*). The function and required arguments are shown below:
```r
sbs_mardie(seed = 23,          # iteration ID
           n_block = 20,        # total number of blocks (squares) that will have transect lines
           block_size = 1000,   # length of each side of the square (in metres)
           n_trns = 60,         # total number of transects across total number of blocks 
                                # (here, 60 transects across 20 blocks = 3 transects/block)

           # Approximate extent from provided map
           xmin = 115.61768, 
           xmax = 116.12871, 
           ymin = -21.35492, 
           ymax = -20.71698)
```
<sup><i>*This script has been updated.</i>

The function can be run multiple times using a different `seed` to generate a new and unique design every time, and produces the following output: 
1) a shapefile (`.shp`) of the blocks and of the transects
2) a `.csv` file containing start and end coordinates of the transects 
3) a `.gpx` version of the `.csv` file which can be read into [Google My Maps](https://www.google.com/maps/about/mymaps/) and/or boating-specific applications
4) an interactive map (`.html`); and
5) a record of the arguments used for the unique iteration (`.txt`)

[Return to main](https://github.com/grcvhon/bci-minerals)