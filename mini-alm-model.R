#Task 2


options(scipen = 999) 

library("shiny")

#Annuties set up

v_p <- function(i,n){
  (1/(1+i))^n}

#Annuity in arrears
a_arrears <- function(n,i){   
  v_n<-v_p(i,n)
  (1-v_n)/i
}

#Bond Pv where cpn = coupon 
bond0<-function(red,i,n){red*v_p(i,n)}
bond_cpn <- function(red, cpn, i, n){
  cpn*a_arrears(n,i) +red *v_p(i,n)
}
#Rounding numeric values up to 4 d.p
r_df <- function(x,d = 4){
  n0_cols <- sapply(x, is.numeric)
  x[n0_cols] <- round(x[n0_cols], d)
  x}

#Pv of assets and liablities 

pmnt<- 1e6  #£1m 

n_yrs<-10 #10 years

i0 <- 0.04 #interest rate at t=0

#Bonds

#Redemption values
r_xx <- 100 #Redemption value of XX
r_yy <- 100 #Redemption value of YY

#Coupon rates
cpn_rt <- 0.03 # 3% Cpn rate YY
cpn_yy <- r_yy * cpn_rt

#Terms
n_xx <- 1; n_yy <-20;

#interest rates (1%....10%)

i_sc <- seq(0.01, 0.10, by = 0.01)

#Pv of liab
pv_t0 <- pmnt * a_arrears(n_yrs, i0) # PV of 1m a angle 10 at 4%
a0 <- pv_t0 # total assets to invest at t = 0

#Bond price at t=0
px0 <- bond0(r_xx, i0, n_xx) #price of bond xx at t=0
py0 <- bond_cpn(r_yy, cpn_yy, i0, n_yy) # price of yy at t=0

#Table at t=0 
t0_results <- data.frame(
  Item = c("PV of Liabilities at t = 0 (£m)",
           "Price of 1-Year Bond XX at t = 0 (£)",
           "Price of 20-Year Bond YY at t = 0 (£)"),
  Value = c(round(pv_t0/1e6, 4), round(px0, 4), round(py0, 4))
)
print(t0_results)


#PV of remaining payments at t = 1 # i = interest rate at t=1 At t = 1: pay 1m immediately, then 9 more annual payments
pv_t1 <- function(i)
{ pmnt + pmnt * a_arrears(9, i)}

#Bond values at t=1
r_xx_t1 <- function(){
  r_xx} #XX redeems at par at t=1

price_yy_t1 <- function(i){   
  # YY now has 19 years left at t=1
  cpn_yy+ bond_cpn(r_yy, cpn_yy, i, n_yy - 1)
}

# Table of values at t = 1 before 1st million
t1_results <- data.frame(
  "Interest Rate t=1 (%)" = i_sc * 100,
  "Price of Bond XX at t=1 (£)" = rep(r_xx_t1(), length(i_sc)),
  "Price of Bond YY at t=1 (£)" = sapply(i_sc, price_yy_t1),
  "PV of Remaining Liabilities (£m)" = round(sapply(i_sc, pv_t1)/1e6, 4)
)
print(t1_results)



#solvency calc.
s_m_for_mix <- function(w_xx, i_vec){w_yy <- (1 - w_xx) #W_xx=proportion in XX,

prop_xx <- ((w_xx * a0)/px0); prop_yy <- ((w_yy * a0)/py0); #Proportion of bonds boughtt at t=0

val_xx_t1 <- prop_xx * r_xx_t1() #Value of XX at t=1

n <- length(i_vec)
a1 <- numeric(n) #Assets value at t=1
pv1 <-numeric(n) #PV of remaining payments at t=1
s <- numeric(n) #solvency ratio

#looping over each interest rate
for(j in 1:n){
  i <- i_vec[j] # interest rate at t=1
  val_yy_t1 <- prop_yy * price_yy_t1(i)
  a1[j]  <- (val_xx_t1 + val_yy_t1); pv1[j] <- (pv_t1(i)); s[j] <- (a1[j] / pv1[j]);}
#Data frame of the weights of XX n YY repeated across all i's
data.frame(w_xx = rep(w_xx, n),   # proportion in XX
           w_yy = rep(w_yy, n),   # proportion in YY
           i = i_vec, # interest rate
           assets_t1 = a1, # total assets at t=1
           pv_liab_t1 = pv1, # PV of liabilities at t=1
           s_ratio = s) # A / PV(L)
}
w_grid <- seq(0, 1, by = 0.1) #possible portfolio splits
mix <- function(w_xx, i_vec){z <- s_m_for_mix(w_xx, i_vec)
data.frame(
  w_xx = w_xx, w_yy = 1- w_xx,
  m_s_m = min(z$s_ratio),a_s_m = all(z$s_ratio>=1))}
s_grd <- do.call(rbind, lapply(w_grid,mix,i_vec=i_sc))

s_grd <-r_df(s_grd)
valid <- s_grd[s_grd$a_s_m,]

if(nrow(valid)>0){
  b_r <-which.max(valid$m_s_m)
  xx_b <-valid$w_xx[b_r]
  yy_b <-1-xx_b
} else{
  xx_b <-NA
  yy_b <-NA}


solvency_grid <- s_grd
names(solvency_grid) <-c(
  "Proportion in XX",
  "Proportion in YY",
  "Minimum Solvency Over All Rates",
  "Solvency >=100% at All Rates?")
print(solvency_grid)




# Solvency for 100% in YY or 100% in XX

solv_0_xx <- s_m_for_mix(0, i_sc)  # 0% XX, 100% YY
names(solv_0_xx) <- c(
  "Proportion in XX",
  "Proportion in YY",
  "Interest Rate (%)",
  "Assets at t=1 (£)",
  "PV of Liabilities (£)",
  "Solvency Ratio")
print(solv_0_xx)

solv_1_xx <- s_m_for_mix(1, i_sc)  # 100% XX, 0% YY
names(solv_1_xx) <- c(
  "Proportion in XX",
  "Proportion in YY",
  "Interest Rate (%)",
  "Assets at t=1 (£)",
  "PV of Liabilities (£)",
  "Solvency Ratio")
print(solv_1_xx)


if(nrow(valid)>0){
  b_r <-which.max(valid$m_s_m)
  xx_b <-valid$w_xx[b_r]
  yy_b <-1-xx_b
} else{
  xx_b <-NA
  yy_b <-NA}
print(xx_b) #Best proportion in XX
print(yy_b) #Best Proportion in YY

sm <- t(sapply(w_grid, function (w){s_m_for_mix(w,i_sc)$s_ratio}))

colnames(sm)<- paste0(round(i_sc *100), "%")

sm_df <- data.frame ( "Proportion in XX (%)" = round(w_grid * 100),
                      "Proportion in YY (%)" = round ((1 - w_grid)*100), round (sm,4),
                      check.names=FALSE)


#Shiny package
ui <- fluidPage(
  #custom CSS for styling the background, found online and changed.
  tags$head(tags$style(HTML(
    "body{background-color: #f6f8fa;font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif;}
     .summarybox{background-color: #ffffff;border-radius: 10px;padding: 15px;margin-bottom: 15px;
    border:1px solid #d6d8db;box-shadow: 0 2px 4px rgba(0,0,0,0.05);}
     .summary-title{font-weight: 600;margin-bottom: 4px;color: #555555;}
     .summary-value{font-size: 1.1em;color: #2c3e50;}
     h4 {margin-top: 25px;}"
  ))),
  
  #Title and main information on the LFH side
  titlePanel("ABC plc – Solvency at t = 1"),
  sidebarLayout(
    sidebarPanel(
      h4("Choose the mix"),
      sliderInput("w_xx",
                  label = "Proportion in 1-year bond XX",
                  min   = 0,
                  max   = 1,
                  value = 0.5,
                  step  = 0.1),
      helpText("The rest is in the 20-year 3% bond YY."),
      hr(),
      helpText("Interest at t = 1 is assumed to be between 1% and 10% pa, in 1% steps.")
    ),
    #Main tap the interactive portfolio
    mainPanel(tabsetPanel(
      tabPanel("Interactive portfolio",
               fluidRow(column(
                 4,div(class = "summarybox", #portfolio split 
                       div(class = "summary-title", "Portfolio split"),
                       div(class = "summary-value", textOutput("sum_port")))),
                 column(4,
                        div(class = "summarybox", #Min solvency
                            div(class = "summary-title", "Minimum solvency"),
                            div(class = "summary-value", textOutput("sum_m_s_m")))),
                 column(4,#test if solvency >=100
                        div(class = "summarybox",div(class= "summary-title", "Solvency >=100% at all rates?"),
                            div(class = "summary-value", textOutput("sum_a_s_m"))))),
               h4("Solvency vs Interest rate"),  #Header
               plotOutput("plot_solv"), #Solvency plot
               br(),
               h4("Solvency table"),
               tableOutput("tbl_solv")),
      tabPanel("Allocation summary", #Allocation summary tap with plot and grid for the mixes
               h4("Minimum solvency for each mix (0%–100% in XX)"),
               plotOutput("plot_alloc"),br(),
               h4("Grid of mixes"),
               tableOutput("tbl_alloc")),
      
      tabPanel("Solvency matrix", h4("Solvency ratio for each mix of XX and YY at each interest rate"),
               tableOutput("tbl_matrix")),
      
      tabPanel("Core calculations", #Showing main calcs such as price of XX and YY
               h4("Present values and bond prices at t = 0"),
               tableOutput("tbl_t0"),
               br(),
               h4("Values at t = 1 (just before the first £1m payment)"),
               tableOutput("tbl_t1"))
    ))))

server <- function(input, output){
  solv_summary <- reactive({ #calculates the changes whenever the slider changes
    df <- s_m_for_mix(input$w_xx, i_sc)
    list(df = df, #table of min solv, if solvency >= 1 at all rates
         min_s_m = min(df$s_ratio),
         a_s_m =all(df$s_ratio >= 1),
         port_text = paste0("XX: ", round(df$w_xx[1] * 100, 1), "%  |  ", "YY: ", round(df$w_yy[1] * 100, 1), "%"))})
  output$plot_solv <- renderPlot({ #plot of solvency @i
    s  <- solv_summary()
    df <- s$df
    plot(df$i * 100, df$s_ratio, type = "l", xlab = "Interest rate at t = 1 (%)",
         ylab = "Solvency ratio",
         main = "Solvency vs interest rate",
         lwd  = 2)
    abline(h = 1, lty = 2, col = "red")
    grid()
  })
  
  output$tbl_solv <- renderTable({ #Table for the current mix
    s  <- solv_summary()
    df <- s$df
    df$assets_t1  <- round(df$assets_t1/1e6, 2)
    df$pv_liab_t1 <- round(df$pv_liab_t1/1e6, 2)
    df$s_ratio<- round(df$s_ratio, 4)
    names(df) <- c( #renaming the tables 
      "Proportion in XX",
      "Proportion in YY",
      "Interest rate at t = 1",
      "Assets at t = 1 (£m)",
      "PV of liabilities at t = 1 (£m)",
      "Solvency ratio")
    df})
  output$sum_port <- renderText({
    s <- solv_summary()
    s$port_text})
  output$sum_m_s_m <- renderText({
    s <- solv_summary()
    round(s$min_s_m, 4)})
  
  output$sum_a_s_m <- renderText({ #ifelse statement for Solvency >= 100?
    s <- solv_summary()
    if (s$a_s_m) {
      "Yes – fully above 100%"
    } else {
      "No, Solvency drops below 100% somewhere"}})
  output$plot_alloc <- renderPlot({ #Summary plot
    df <- s_grd
    plot(df$w_xx *100, df$m_s_m,
         type = "b", xlab = "Proportion in XX (%)", ylab = "Minimum solvency (over 1%–10%)", main = "How mix affects worst-case solvency",
         pch  = 16)
    abline(h = 1, lty = 2, col = "red")
    #if an optimal mix find its minimum solvency and label it
    if (!is.na(xx_b)) {y_best <- df$m_s_m[df$w_xx == xx_b]
    points(xx_b * 100, y_best,
           pch = 16, col = "darkgreen", cex = 1.4)
    text(xx_b * 100, y_best,
         labels = " best", pos = 4, col = "darkgreen")}
    grid()
  })
  
  
  output$tbl_alloc <- renderTable({
    df <- s_grd
    df$a_s_m <- NULL
    names(df) <- c(
      "Proportion in XX",
      "Proportion in YY",
      "Minimum solvency")
    df
  })
  output$tbl_matrix <- renderTable ({ sm_df}, rownames=TRUE)
  #renaming columns
  output$tbl_t0 <- renderTable({
    data.frame(
      Quantity = c(
        "PV of liabilities at t = 0",
        "Price of 1-year bond XX at t = 0",
        "Price of 20-year 3% bond YY at t = 0"
      ),
      Value = c(
        round(pv_t0 / 1e6, 4),  # liabilities in £m
        round(px0, 2),          # bond prices in £
        round(py0, 2)
      ),Units = c("£m", "£", "£"), check.names = FALSE)})
  output$tbl_t1 <- renderTable({
    data.frame(
      "Interest rate at t = 1"  = i_sc,
      "Price of XX at t = 1 (£)"    = rep(r_xx_t1(), length(i_sc)),
      "Price of YY at t = 1 (£)"  = sapply(i_sc, price_yy_t1),
      "PV of remaining liabilities (£m)"= round(sapply(i_sc, pv_t1) / 1e6, 4),
      check.names = FALSE
    )
  })
  
  
}

shinyApp(ui = ui, server = server)


