using Matrix

# NB: code here is adapted from https://github.com/cysouw/qlcMatrix/blob/master/R/assoc.R

# poisson
poi <- function(o,e) { sign(o-e) * (o * log(o/e) - (o-e)) }
# pointwise mutual information, aka "log-odds" in bioinformatics
pmi <- function(o,e) { log(o/e) }
# weighted pointwise mutual information, i.e the basis for MI
wpmi <- function(o,e) { o * log(o/e)}
# pearson residuals
res <- function(o,e) { (o-e) / sqrt(e) }
# NPMI
npmi <- function(o,e) { log(o/e)/(-log(o)) }


# this function expects a dataframe with doc_id and term columns
# doc_id is the identifier for an article
# term is a string such as "wheat_straw" or "biogas"
calculate_CoOccurrence_Metrics <- function(entitiesPerDoc){

  entitiesPerDoc$doc_id = as.character(entitiesPerDoc$doc_id)

  a = Matrix(0, nrow = length(unique(entitiesPerDoc$doc_id)), ncol = length(unique(entitiesPerDoc$term)))
  colnames(a) = sort(unique(entitiesPerDoc$term))
  rownames(a) = sort(unique(entitiesPerDoc$doc_id))

  idLookup = c(1:length(rownames(a)))
  names(idLookup) = rownames(a)

  termLookup = c(1:length(colnames(a)))
  names(termLookup) = colnames(a)

  indices = cbind(idLookup[entitiesPerDoc$doc_id], termLookup[entitiesPerDoc$term])
  a[indices] = 1

  N = nrow(a)
  
  X = a
  X <- as(X,"ngCMatrix")*1
  Fx <- Matrix::colSums(X)

  co_occur_count = Matrix::crossprod(X)
  O <- co_occur_count/N

  R <- as(O,"nMatrix")

  Fx <- Diagonal( x = Fx )/N

  E <- Fx %*% R %*% Fx
  E <- as(E,"symmetricMatrix")

  o = O
  e = E

  npmi_vals = npmi(o,e)
  pmi_vals = pmi(o,e)
  wpmi_vals = wpmi(o,e)
  poi_vals = poi(o,e)
  pearson_res_vals = res(o,e)

  nonNaNIndices = Matrix::which(!is.na(npmi_vals), arr.ind=TRUE)
  df = data.frame(from = rownames(O)[nonNaNIndices[,1]],
                  to = rownames(O)[nonNaNIndices[,2]],
                  pmi = pmi_vals[nonNaNIndices],
                  poi = poi_vals[nonNaNIndices],
                  npmi = npmi_vals[nonNaNIndices],
                  wpmi = wpmi_vals[nonNaNIndices],
                  pearson = pearson_res_vals[nonNaNIndices],
                  co_occur = co_occur_count[nonNaNIndices])

  return(list(metrics = df, docTermMatrix = a))
}
