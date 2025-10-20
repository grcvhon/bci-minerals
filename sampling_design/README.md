# Generating a sampling design across the Mardie region

Discussion is ongoing as to how best assess sea snake biodiversity and populations in the Mardie region in relation to the BCI Minerals Project. Below are links to different versions of generated designs which were developed following communications with O2 Marine.

#### <b>List of contents</b><br>
1) [SBS design prioritising BRUV deployment sites & SNSS sampling sites](#1-spatially-balanced-sampling-design-prioritising-bruv-deployment-sites--snss-sampling-sites)
2) [SBS design prioritising BRUV deployment sites & SNSS sampling sites, dredge area, spoil area](#2-sbs-design-prioritising-bruv-deployment-sites--snss-sampling-sites-dredge-area-spoil-area)

<sup><i>SBS = Spatially balanced sampling; SNSS = Short-nosed sea snake</i></sup>

##
### 1) Spatially balanced sampling design prioritising BRUV deployment sites & SNSS sampling sites

We will generate a spatially balanced sampling design across the Mardie region while taking into account indicative sampling sites for the Short-nosed sea snake (<i>Aipyusurus apraefrontalis</i>) as presented in the image below. That is, our design will prioritise these identified sites/will increase their inclusion probability when generating a spatially balanced design. 

<p align = "center">
<img src="https://raw.githubusercontent.com/grcvhon/bci-minerals/main/misc/image.png", width = 50%, height = 50%>
<div align = "center">
<i><sup>(Source: Daniella Hanf, O2 Marine)</sup></i>
</div>
</p>

Here, "spatially balanced" means that the sampling sites we will place within the survey boundary (approximated from the map above) will most likely yield adequate representative data of the sea snake species occurring within the area including the Short-nosed sea snake. 

To execute this systematic sampling approach, the process will place <i>x</i> number of blocks that each have <i>y</i> number of transect lines. These blocks will be placed within the survey area irrespective of its biotic and abiotic characteristics and will only optimise for spatially balanced sampling coverage. However, as mentioned earlier, we have modified the process so that we can still generate a spatially balanced design while putting more weight on the indicative sampling sites for the Short-nosed sea snake. 

Typically, we generate a 1 km<sup>2</sup>-block containing three 1-km transect lines connected in a zig-zag configuration, starting from one corner of the block. Using a zig-zag formation increases the efficiency of sampling within the block. From experience, a quiet set of transect lines i.e. a block with no snakes takes about 10 minutes to traverse under ideal weather conditions.

We created a custom function (`sbs_mardie`) that will automate the entire process (see function script [here](https://github.com/grcvhon/bci-minerals/blob/main/sampling_design/fn_sbs_mardie.R)). The function and required arguments are shown below:
```r
sbs_mardie(seed = 777,          # iteration ID
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
This function produces the following output: 
1) shapefiles (`.shp`) of the blocks and of the transects
2) a `.csv` file containing start and end coordinates of the transects 
3) a `.gpx` version of the `.csv` file which can be read into [Google My Maps](https://www.google.com/maps/about/mymaps/) and/or boating-specific applications
4) an interactive map (`.html`); and
5) a record of the arguments used for the unique iteration (`.txt`)

The function can be run multiple times using a different `seed` to generate a new and unique design every time.

Below is a preview of the output. Associated output files for the set of arguments used can be found [here](https://github.com/grcvhon/bci-minerals/tree/main/sampling_design/output/seed23_1000m_20blocks_60samplers).
```
Arguments used: 
    seed = 23, n_block = 20, block_size = 1000, n_trns = 60, 
    xmin = 115.61768, xmax = 116.12871, 
    ymin = -21.35492, ymax = -20.71698
```



<p align = "center">
<img src="https://raw.githubusercontent.com/grcvhon/bci-minerals/main/misc/seed23_preview.png", width = 50%, height = 50%>
<div align = "center">
<sup>Spatially balanced sampling design of 20 total blocks and 60 total transect lines (ID: 23).</sup>
</div>
</p>

[Back to top](#)
##

### 2) SBS design prioritising BRUV deployment sites & SNSS sampling sites, dredge area, spoil area

In this version, we incorporate the dredge and spoil areas of the BCI Minerals Project when coming up with a spatially balanced sampling design. Details about these areas are available via the [Mardie Project
Dredge and Spoil Disposal Management Plan](https://www.epa.wa.gov.au/sites/default/files/Referral_Documentation/Att3_DSDMP%20%28O2%20Marine%2C%202025%29.pdf) (pp. 10,11).

We first show the dredge and spoil areas in the context of the region.<br>

<p align = "center">
<img src="https://raw.githubusercontent.com/grcvhon/bci-minerals/main/misc/overview_impact.png", width = 50%, height = 50%>
<div align = "center">
<sup>
Dredge area (closer to shore) is approximately 0.59 km<sup>2</sup>. Spoil dump area (offshore rectangle) is approximately 0.30 km<sup>2</sup>.
</sup>
</div>
</p>

We think that it is important to assess the levels of sea snake diversity and/or abundance before and after dredging and dumping of spoil. Therefore, we will incorporate these areas into our sampling design. Since we want to explicitly have transect lines within these identified areas, we will add them manually after we have generated our spatially balanced sampling design.

[Back to top](#)