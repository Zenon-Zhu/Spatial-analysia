Life_span_generation_kWH <- function (yearly_generation_kWH, discount = 0.03, lifetime_yrs = 25){
  t<- seq(1, lifetime_yrs, 1)
  L_S_G <- sum(yearly_generation_kWH/(1+discount)**t)
  return (round(L_S_G,0))
}

LCOE <- function(NPV,Life_span_generation){
  lcoe <- NPV/Life_span_generation
  return(round(lcoe,2))
}
annual= 71510800000 #kwh
lsg = Life_span_generation_kWH(yearly_generation_kWH=annual)
lsg
npv=288129748000
lcoe = LCOE(NPV=npv, lsg)
npv
lcoe 