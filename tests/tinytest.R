
if ( requireNamespace("tinytest", quietly=TRUE) ){
  home <- identical(Sys.info()[["nodename"]], "manjdell")
  tinytest::test_package("fertplan", at_home = home)
}

