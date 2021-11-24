library(dplyr)
library(ggplot2)

enrollRates <- tibble::tibble(Stratum = "All", duration = 12, rate = 500/12)

failRates <- tibble::tibble(Stratum = "All",
                            duration = c(4, 100),
                            failRate = log(2) / 15,  # median survival 15 month
                            hr = c(1, .6),         
                            dropoutRate = 0.001)

## Weight function
weight_fun <- list(
  function(x, arm0, arm1){ gsdmvn:::wlr_weight_fh(x, arm0, arm1, rho = 0, gamma = 0)},
  function(x, arm0, arm1){ gsdmvn:::wlr_weight_fh(x, arm0, arm1, rho = 0.5, gamma = 0.5)},
  function(x, arm0, arm1){ gsdmvn:::wlr_weight_fh(x, arm0, arm1, rho = 0, gamma = 0.5)},
  function(x, arm0, arm1){ gsdmvn:::wlr_weight_fh(x, arm0, arm1, rho = 0, gamma = 1)}
)

## Weight name
weight_name <- data.frame(rho = c(0, 0.5, 0, 0), gamma = c(0, 0.5, 0.5, 1))
weight_name <- with(weight_name, paste0("rho = ", rho, "; gamma = ", gamma) ) 

## gs_info_wlr 
t <- seq(2, 36, by = 2)
gs_info <- lapply(weight_fun, function(weight){
  tmp <- gsdmvn:::gs_info_wlr(enrollRates, failRates, 
                              analysisTimes = t, 
                              weight = weight)
  
  tmp %>% mutate(
    theta = abs(delta) / sqrt(sigma2),
    info = info / max(info),
    info0 = info0 / max(info0)
  )
})
names(gs_info) <- weight_name

gs_info <- bind_rows(gs_info, .id = "weight") %>% 
           mutate(weight = factor(weight, levels = unique(weight)))

## Create Figure Common part

g <- ggplot(data = gs_info, mapping = aes(x = Time, group = weight, color = weight) ) + 
     scale_x_continuous(name="Calendar Time (Month)", limits=c(0, 36), breaks = seq(0, 36, by = 6)) +
     theme_bw()

## Generate Figure
g_ahr <- g + geom_line(aes(y = AHR)) + 
             ylab("Average Hazard Ratio")

g_theta <- g + geom_line(aes(y = theta)) +
               ylab("Effect Size (theta)")

g_info <- g + geom_line(aes(y = info), linetype = "solid") +
              geom_line(aes(y = info0), linetype = "dashed") +
              annotate("text", x = 1, y = c(0.95, 1), hjust = 0,  label = c("Solid line: Under Alternative", "Dashed line: Under Null")) +
              ylab("Information Fraction")



ggsave(file = "images/g_ahr.png",   g_ahr,   width = 8, height = 5)
ggsave(file = "images/g_theta.png", g_theta, width = 8, height = 5)
ggsave(file = "images/g_info.png",  g_info,  width = 8, height = 5)

#--------------- Spending Function--------------------#
analysisTimes <- c(12, 24, 36)
spend <- lapply(weight_fun, function(weight){
  tmp <- gsdmvn:::gs_info_wlr(enrollRates, failRates, 
                              analysisTimes = analysisTimes, 
                              weight = weight)
  
  tmp %>% mutate(
    theta = abs(delta) / sqrt(sigma2),
    info = info / max(info),
    info0 = info0 / max(info0), 
    alpha = gsDesign::sfLDOF(alpha = 0.025, t = info0)$spend, 
    beta    = gsDesign::sfLDOF(alpha = 0.20, t = info)$spend
  ) 
})
names(spend) <- weight_name
gs_spend <- bind_rows(spend, .id = "weight") %>% 
            mutate(weight = factor(weight, levels = unique(weight)))

g1 <- ggplot(data = gs_spend, mapping = aes(x = Time, group = weight, color = weight) ) + 
  scale_x_continuous(name="Calendar Time (Month)", limits=c(0, 36), breaks = seq(0, 36, by = 6)) +
  theme_bw()

g_alpha <- g1 + geom_line(aes(y = alpha)) + 
  ylab("Cumulative alpha-Spending")

g_beta <- g1 + geom_line(aes(y = beta)) + 
  ylab("Cumulative beta-Spending")

ggsave(file = "images/g_alpha.png", g_alpha, width = 8, height = 5)
ggsave(file = "images/g_beta.png",  g_beta,  width = 8, height = 5)

## Bound

n <- 500
bound <- lapply(spend, function(db){
  corr <- outer(db$info0, db$info0, function(x,y) pmin(x,y) / pmax(x,y))
  tmp <- gsdmvn:::gs_bound(db$alpha, db$beta, theta = db$theta * sqrt(n), corr = corr)
  tmp$analysis <- 1:length(db$alpha)
  tmp
})
bound <- bind_rows(bound, .id = "weight") %>% 
         mutate(weight = factor(weight, levels = unique(weight)))

bound_500 <- bound %>% mutate(upper = pmin(upper, 5))

n <- 400
bound <- lapply(spend, function(db){
  corr <- outer(db$info0, db$info0, function(x,y) pmin(x,y) / pmax(x,y))
  tmp <- gsdmvn:::gs_bound(db$alpha, db$beta, theta = db$theta * sqrt(n), corr = corr)
  tmp$analysis <- 1:length(db$alpha)
  tmp
})
bound <- bind_rows(bound, .id = "weight") %>% 
         mutate(weight = factor(weight, levels = unique(weight)))

bound_400 <- bound %>% mutate(upper = pmin(upper, 5))

g2 <- ggplot(data = bound_500, mapping = aes(x = analysis, group = weight, color = weight) ) + 
      theme_bw()

g_bound <- g2 + geom_line(aes(y = lower)) + 
                geom_line(aes(y = lower), linetype = "dashed", data = bound_400) +
                geom_line(aes(y = upper)) + 
                scale_x_continuous("Analysis (k)", breaks = 1:3, limits = c(1,3)) +
                scale_y_continuous("Bound", limits = c(-5, 5)) + 
                annotate("text", x = 3, y = - 5, hjust = 1, label = "Upper bound is capped at 5, i.e. max(upper, 5)") +
                annotate("text", x = 3, y = c(4.5, 5), hjust = 1, 
                         label = c("Dashed Line: N = 400", "Solid Line: N = 500"))

g_bound                

ggsave(file = "images/g_bound.png",  g_bound,  width = 8, height = 5)
