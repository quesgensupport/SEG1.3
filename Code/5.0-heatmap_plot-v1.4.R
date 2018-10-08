# =====================================================================#
# This is code to create: the plot for the heatmap used in the SEG_shiny
# app. The Github repo for this project is available here:

# Authored by and feedback to mjfrigaard@gmail.com
# MIT License
# Version: 1.4
# =====================================================================#

# 5 - HEAT MAP DATA INPUTS ============= ----
#
# 5.0 upload AppRiskPairData.csv from github  ---- ---- ---- ----
app_riskpair_repo <- "mjfrigaard/SEG_shiny/master/Data/AppRiskPairData.csv"
RiskPairData <- read_csv(paste0(github_root, app_riskpair_repo))

# 5.1 mmol conversion factor ---- ---- ---- ---- ---- ---- ----
mmolConvFactor <- 18.01806

# 5.2 rgb2hex function ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
# This is the RGB to Hex number function for R
rgb2hex <- function(r, g, b) rgb(r, g, b, maxColorValue = 255)

# 5.3 risk factor colors ---- ---- ---- ---- ---- ---- ---- ---- ----
# These are the values for the colors in the heatmap.
abs_risk_0.0000_color <- rgb2hex(0, 165, 0)
# abs_risk_0.0000_color
abs_risk_0.4375_color <- rgb2hex(0, 255, 0)
# abs_risk_0.4375_color
abs_risk_1.0625_color <- rgb2hex(255, 255, 0)
# abs_risk_1.0625_color
abs_risk_2.7500_color <- rgb2hex(255, 0, 0)
# abs_risk_2.7500_color
abs_risk_4.0000_color <- rgb2hex(128, 0, 0)
# abs_risk_4.0000_color
riskfactor_colors <- c(
  abs_risk_0.0000_color,
  abs_risk_0.4375_color,
  abs_risk_1.0625_color,
  abs_risk_2.7500_color,
  abs_risk_4.0000_color
)

# 5.4 create base_data data frame ---- ---- ---- ---- ---- ---- ---- ----
base_data <- data.frame(
  x_coordinate = 0,
  y_coordinate = 0,
  color_gradient = c(0:4)
)

# 5.5 base layer ---- ---- ---- ---- ---- ---- ---- ----
base_layer <- ggplot() +
  geom_point(
    data = base_data, # defines data frame
    aes(
      x = x_coordinate,
      y = y_coordinate,
      fill = color_gradient
    )
  ) # + # uses x, y, color_gradient
# 5.6 risk pair data layer  ---- ---- ---- ---- ---- ---- ---- ----
# RiskPairData %>% glimpse(78)
risk_layer <- base_layer +
  geom_point(
    data = RiskPairData, # new data set
    aes(
      x = REF, # additional aesthetics from new data set
      y = BGM,
      color = abs_risk
    ),
    show.legend = FALSE
  )
# 5.7 add fill gradient  ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
risk_layer_gradient <- risk_layer +
  ggplot2::scale_fill_gradientn( # scale_*_gradientn creats a n-color gradient
    values = scales::rescale(c(
      0, # darkgreen
      0.4375, # green
      1.0625, # yellow
      2.75, # red
      4.0
    )), # brown
    limits = c(0, 4),
    colors = riskfactor_colors,
    guide = guide_colorbar(
      ticks = FALSE,
      barheight = unit(100, "mm")
    ),
    breaks = c(
      0.25,
      1,
      2,
      3,
      3.75
    ),
    labels = c(
      "none",
      "slight",
      "moderate",
      "high",
      "extreme"
    ),
    name = "risk level"
  )

# 5.8 add color gradient  ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
# Add the new color scales to the scale_y_continuous()
heatmap_plot <- risk_layer_gradient +
  ggplot2::scale_color_gradientn(
    colors = riskfactor_colors, # these are defined above
    guide = "none",
    limits = c(0, 4),
    values = scales::rescale(c(
      0, # darkgreen
      0.4375, # green
      1.0625, # yellow
      2.7500, # red
      4.0000
    ))
  ) +
  ggplot2::scale_y_continuous(
    limits = c(0, 600),
    sec.axis =
      sec_axis(~. / mmolConvFactor,
        name = "measured blood glucose (mmol/L)"
      ),
    name = "measured blood glucose (mg/dL)"
  ) +
  scale_x_continuous(
    limits = c(0, 600),
    sec.axis =
      sec_axis(~. / mmolConvFactor,
        name = "reference blood glucose (mmol/L)"
      ),
    name = "reference blood glucose (mg/dL)"
  )


# export plot template  ---- ---- ---- ---- ---- ---- ---- ---- ----
save(heatmap_plot, file = "Data/heatmap_plot.RData")
