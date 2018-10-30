# Step 1: Installing packages and dependencies via supplied binary packages
update.packages(ask=FALSE)

packages <- c(
"sparklyr",
"fs",
"reticulate",
"getPass",
"Hmisc",
"Rcpp",
"bookdown",
"docxtractr",
"odbc",
"evaluate",
"gbm",
"randomForest",
"data.table",
"smbinning",
"ClustOfVar",
"corrplot",
"foreach",
"doParallel",
"xgboost",
"expm",
"rlang",
"remotes",
"flextable"
)

install.packages(packages)
